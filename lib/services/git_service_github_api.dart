import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'git_service.dart';

/// Git service implementation using GitHub REST API.
/// Works on iOS/Android where the git binary is not available and
/// git_on_dart's remote operations (fetch/pull/push) are incomplete.
///
/// Local files are the source of truth. Remote is synced via API.
class GitServiceGithubApi implements GitService {
  bool _initialized = false;
  String? _repoPath;
  String _owner = '';
  String _repoName = '';
  String? _pat;
  String _defaultBranch = 'main';

  // Remote state from last pull
  Map<String, String> _remoteShas = {}; // path -> blob SHA
  DateTime _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(0);

  String get _syncStatePath => '$_repoPath/.dottr/sync_state.json';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize(String repoPath) async {
    _repoPath = repoPath;
    await Directory(repoPath).create(recursive: true);
    await _loadSyncState();
    _initialized = true;
    developer.log('GitServiceGithubApi: initialized at $_repoPath');
  }

  // ── URL parsing ────────────────────────────────────────────────

  void _parseRepoUrl(String url) {
    // https://github.com/owner/repo.git → owner, repo
    var cleaned = url.replaceAll('.git', '').trim();
    if (cleaned.endsWith('/')) cleaned = cleaned.substring(0, cleaned.length - 1);
    final uri = Uri.parse(cleaned);
    final segments = uri.pathSegments;
    if (segments.length >= 2) {
      _owner = segments[segments.length - 2];
      _repoName = segments[segments.length - 1];
    }
    developer.log('GitServiceGithubApi: owner=$_owner repo=$_repoName');
  }

  // ── Sync state persistence ────────────────────────────────────

  Future<void> _loadSyncState() async {
    try {
      final file = File(_syncStatePath);
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString());
        _remoteShas = Map<String, String>.from(json['remoteShas'] ?? {});
        _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(
          json['lastSyncMs'] ?? 0,
        );
        _defaultBranch = json['defaultBranch'] ?? 'main';
        _owner = json['owner'] ?? '';
        _repoName = json['repoName'] ?? '';
      }
    } catch (e) {
      developer.log('GitServiceGithubApi: sync state load failed: $e');
    }
  }

  Future<void> _saveSyncState() async {
    try {
      final file = File(_syncStatePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode({
        'remoteShas': _remoteShas,
        'lastSyncMs': _lastSyncTime.millisecondsSinceEpoch,
        'defaultBranch': _defaultBranch,
        'owner': _owner,
        'repoName': _repoName,
      }));
    } catch (e) {
      developer.log('GitServiceGithubApi: sync state save failed: $e');
    }
  }

  // ── HTTP helpers ──────────────────────────────────────────────

  Future<(int statusCode, String body)> _apiCall(
    String method,
    String path, {
    Object? jsonBody,
    String? pat,
  }) async {
    final p = pat ?? _pat;
    final client = HttpClient();
    try {
      final uri = Uri.parse('https://api.github.com$path');
      final request = await (switch (method) {
        'GET' => client.getUrl(uri),
        'POST' => client.postUrl(uri),
        'PUT' => client.putUrl(uri),
        'PATCH' => client.patchUrl(uri),
        _ => client.openUrl(method, uri),
      });
      if (p != null) request.headers.set('Authorization', 'token $p');
      request.headers.set('Accept', 'application/vnd.github.v3+json');
      request.headers.set('User-Agent', 'Dottr');
      if (jsonBody != null) {
        request.headers.set('Content-Type', 'application/json');
        request.write(jsonEncode(jsonBody));
      }
      final resp = await request.close();
      final body = await resp.transform(utf8.decoder).join();
      return (resp.statusCode, body);
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> _apiGet(String path, {String? pat}) async {
    final (status, body) = await _apiCall('GET', path, pat: pat);
    if (status == 404) {
      throw GitException('Not found: $path', exitCode: 404, stderr: body);
    }
    if (status != 200) {
      throw GitException(
        'GitHub API error $status',
        exitCode: status,
        stderr: body,
      );
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _apiPost(
    String path,
    Object body, {
    String? pat,
  }) async {
    final (status, respBody) =
        await _apiCall('POST', path, jsonBody: body, pat: pat);
    if (status != 200 && status != 201) {
      throw GitException(
        'GitHub API error $status',
        exitCode: status,
        stderr: respBody,
      );
    }
    return jsonDecode(respBody) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _apiPatch(
    String path,
    Object body, {
    String? pat,
  }) async {
    final (status, respBody) =
        await _apiCall('PATCH', path, jsonBody: body, pat: pat);
    if (status != 200) {
      throw GitException(
        'GitHub API error $status',
        exitCode: status,
        stderr: respBody,
      );
    }
    return jsonDecode(respBody) as Map<String, dynamic>;
  }

  // ── File helpers ──────────────────────────────────────────────

  /// Collect all syncable files under [dir], relative to [_repoPath].
  Future<Map<String, File>> _collectLocalFiles() async {
    final files = <String, File>{};
    final root = Directory(_repoPath!);
    if (!await root.exists()) return files;

    await for (final entity in root.list(recursive: true)) {
      if (entity is! File) continue;
      final rel = entity.path.substring(_repoPath!.length + 1);
      // Skip git internals and sync state
      if (rel.startsWith('.git/') || rel.startsWith('.git\\')) continue;
      if (rel == '.dottr/sync_state.json') continue;
      files[rel] = entity;
    }
    return files;
  }

  // ── GitService interface ──────────────────────────────────────

  @override
  Future<void> clone(String repoUrl, String targetPath, {String? pat}) async {
    _pat = pat;
    _parseRepoUrl(repoUrl);
    _repoPath = targetPath;
    await Directory(targetPath).create(recursive: true);
    _initialized = true;

    // Detect default branch
    try {
      final repoInfo = await _apiGet('/repos/$_owner/$_repoName', pat: pat);
      _defaultBranch = repoInfo['default_branch'] ?? 'main';
    } catch (_) {
      _defaultBranch = 'main';
    }

    // Download all files
    await pull(pat: pat);
    developer.log('GitServiceGithubApi: cloned → $targetPath');
  }

  @override
  Future<void> pull({String? pat}) async {
    _ensureInitialized();
    final p = pat ?? _pat;
    if (p == null || _owner.isEmpty) {
      throw GitException('pull: not configured (no PAT or repo)');
    }
    _pat = p;

    try {
      // Get remote tree
      final tree = await _apiGet(
        '/repos/$_owner/$_repoName/git/trees/$_defaultBranch?recursive=1',
        pat: p,
      );

      final entries = tree['tree'] as List;
      final newRemoteShas = <String, String>{};

      for (final entry in entries) {
        if (entry['type'] != 'blob') continue;
        final path = entry['path'] as String;
        final sha = entry['sha'] as String;
        newRemoteShas[path] = sha;

        // Skip sync state file
        if (path == '.dottr/sync_state.json') continue;

        // Only download if SHA changed (new or modified on remote)
        if (_remoteShas[path] == sha) continue;

        // Download blob
        final blob = await _apiGet(
          '/repos/$_owner/$_repoName/git/blobs/$sha',
          pat: p,
        );
        final raw = blob['content'].toString().replaceAll('\n', '');
        final content = utf8.decode(base64.decode(raw));

        final localFile = File('$_repoPath/$path');

        // Conflict: local file exists and differs from what we last pulled
        if (await localFile.exists() && _remoteShas[path] != null) {
          // File was updated on remote AND locally since last sync
          final localContent = await localFile.readAsString();
          if (localContent != content) {
            // Keep both versions
            final dot = path.lastIndexOf('.');
            final base = dot > 0 ? path.substring(0, dot) : path;
            final ext = dot > 0 ? path.substring(dot) : '';
            final ts = DateTime.now().millisecondsSinceEpoch;
            final localCopy = File('$_repoPath/$base-local-$ts$ext');
            await localCopy.writeAsString(localContent);
            developer.log('GitServiceGithubApi: conflict on $path — kept both');
          }
        }

        await localFile.parent.create(recursive: true);
        await localFile.writeAsString(content);
      }

      _remoteShas = newRemoteShas;
      _lastSyncTime = DateTime.now();
      await _saveSyncState();
      developer.log('GitServiceGithubApi: pull complete (${entries.length} remote files)');
    } on GitException catch (e) {
      if (e.exitCode == 404 || e.exitCode == 409) {
        // Empty repo or no branch yet — not an error
        developer.log('GitServiceGithubApi: remote is empty, nothing to pull');
        _lastSyncTime = DateTime.now();
        await _saveSyncState();
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> push({String? pat}) async {
    _ensureInitialized();
    final p = pat ?? _pat;
    if (p == null || _owner.isEmpty) {
      throw GitException('push: not configured (no PAT or repo)');
    }
    _pat = p;

    final localFiles = await _collectLocalFiles();
    if (localFiles.isEmpty) return;

    // Find files that need pushing (new or modified since last sync)
    final filesToPush = <String, String>{}; // path -> content
    for (final entry in localFiles.entries) {
      final path = entry.key;
      final file = entry.value;
      final stat = await file.stat();

      // Push if: file is new (no remote SHA) or modified after last sync
      if (!_remoteShas.containsKey(path) ||
          stat.modified.isAfter(_lastSyncTime)) {
        filesToPush[path] = await file.readAsString();
      }
    }

    if (filesToPush.isEmpty) {
      developer.log('GitServiceGithubApi: nothing to push');
      return;
    }

    // Check if repo is empty — Git Data API returns 409 on empty repos
    final repoEmpty = await _isRepoEmpty(p);
    if (repoEmpty) {
      await _pushViaContentsApi(filesToPush, p);
    } else {
      await _pushViaGitDataApi(filesToPush, p);
    }
  }

  /// Check if the GitHub repo has any commits.
  Future<bool> _isRepoEmpty(String pat) async {
    try {
      final (status, _) = await _apiCall(
        'GET',
        '/repos/$_owner/$_repoName/git/ref/heads/$_defaultBranch',
        pat: pat,
      );
      return status == 404 || status == 409;
    } catch (_) {
      return true;
    }
  }

  /// Push files to an empty repo using the Contents API.
  /// This creates one commit per file but works on repos with no commits.
  Future<void> _pushViaContentsApi(
    Map<String, String> files,
    String pat,
  ) async {
    developer.log(
      'GitServiceGithubApi: repo is empty, using Contents API for ${files.length} file(s)',
    );
    for (final entry in files.entries) {
      final encoded = base64.encode(utf8.encode(entry.value));
      final resp = await _apiCall(
        'PUT',
        '/repos/$_owner/$_repoName/contents/${entry.key}',
        jsonBody: {
          'message': 'Add ${entry.key} from Dottr',
          'content': encoded,
          'branch': _defaultBranch,
        },
        pat: pat,
      );
      if (resp.$1 != 200 && resp.$1 != 201) {
        throw GitException(
          'Contents API error ${resp.$1} for ${entry.key}',
          exitCode: resp.$1,
          stderr: resp.$2,
        );
      }
      final data = jsonDecode(resp.$2) as Map<String, dynamic>;
      final content = data['content'] as Map<String, dynamic>?;
      if (content != null && content['sha'] != null) {
        _remoteShas[entry.key] = content['sha'] as String;
      }
    }
    _lastSyncTime = DateTime.now();
    await _saveSyncState();
    developer.log(
      'GitServiceGithubApi: pushed ${files.length} file(s) via Contents API',
    );
  }

  /// Push files using the Git Data API (blobs → tree → commit → ref update).
  /// Only works on repos that already have at least one commit.
  Future<void> _pushViaGitDataApi(
    Map<String, String> files,
    String pat,
  ) async {
    try {
      // Get current HEAD
      final ref = await _apiGet(
        '/repos/$_owner/$_repoName/git/ref/heads/$_defaultBranch',
        pat: pat,
      );
      final headSha = ref['object']['sha'] as String;
      final commit = await _apiGet(
        '/repos/$_owner/$_repoName/git/commits/$headSha',
        pat: pat,
      );
      final baseTreeSha = commit['tree']['sha'] as String;

      // Create blobs + build tree entries
      final treeItems = <Map<String, dynamic>>[];
      for (final entry in files.entries) {
        final blob = await _apiPost(
          '/repos/$_owner/$_repoName/git/blobs',
          {
            'content': base64.encode(utf8.encode(entry.value)),
            'encoding': 'base64',
          },
          pat: pat,
        );
        treeItems.add({
          'path': entry.key,
          'mode': '100644',
          'type': 'blob',
          'sha': blob['sha'],
        });
      }

      // Create tree
      final tree = await _apiPost(
        '/repos/$_owner/$_repoName/git/trees',
        {'base_tree': baseTreeSha, 'tree': treeItems},
        pat: pat,
      );

      // Create commit
      final newCommit = await _apiPost(
        '/repos/$_owner/$_repoName/git/commits',
        {
          'message': 'Sync from Dottr',
          'tree': tree['sha'],
          'parents': [headSha],
        },
        pat: pat,
      );
      final commitSha = newCommit['sha'] as String;

      // Update branch ref
      await _apiPatch(
        '/repos/$_owner/$_repoName/git/refs/heads/$_defaultBranch',
        {'sha': commitSha},
        pat: pat,
      );

      // Update remote SHAs
      for (final item in treeItems) {
        _remoteShas[item['path'] as String] = item['sha'] as String;
      }
      _lastSyncTime = DateTime.now();
      await _saveSyncState();

      developer.log(
        'GitServiceGithubApi: pushed ${files.length} file(s) → $commitSha',
      );
    } on GitException {
      rethrow;
    } catch (e) {
      throw GitException('push failed', stderr: e.toString());
    }
  }

  @override
  Future<void> add(String filePath) async {
    // No-op: API push handles file collection
  }

  @override
  Future<void> addAll() async {
    // No-op: API push handles file collection
  }

  @override
  Future<void> commit(String message) async {
    // No-op: push creates commits via API
  }

  @override
  Future<bool> hasChanges() async {
    _ensureInitialized();
    final localFiles = await _collectLocalFiles();
    for (final entry in localFiles.entries) {
      if (!_remoteShas.containsKey(entry.key)) return true;
      final stat = await entry.value.stat();
      if (stat.modified.isAfter(_lastSyncTime)) return true;
    }
    return false;
  }

  @override
  Future<bool> isGitRepo() async {
    // For the API service, we consider it a "repo" if sync state exists
    if (_repoPath == null) return false;
    return File(_syncStatePath).exists();
  }

  @override
  Future<void> initRepo() async {
    _ensureInitialized();
    // Just create the sync state
    await _saveSyncState();
    developer.log('GitServiceGithubApi: init at $_repoPath');
  }

  @override
  Future<void> setRemoteUrl(String url, {String? pat}) async {
    _parseRepoUrl(url);
    _pat = pat;
    // Detect default branch
    try {
      final repoInfo = await _apiGet('/repos/$_owner/$_repoName', pat: pat);
      _defaultBranch = repoInfo['default_branch'] ?? 'main';
    } catch (_) {
      _defaultBranch = 'main';
    }
    await _saveSyncState();
  }

  @override
  Future<bool> hasRemote() async {
    return _owner.isNotEmpty && _repoName.isNotEmpty;
  }

  @override
  Future<void> configUser(String name, String email) async {
    // No-op: commits are created via API with Dottr author
  }

  void _ensureInitialized() {
    if (!_initialized || _repoPath == null) {
      throw GitException('GitService not initialized');
    }
  }
}
