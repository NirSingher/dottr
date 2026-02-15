import 'dart:developer' as developer;
import 'dart:io';
import 'git_service.dart';

class GitServiceImpl implements GitService {
  bool _initialized = false;
  String? _repoPath;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize(String repoPath) async {
    _repoPath = repoPath;
    _initialized = true;
    developer.log('GitService: initialized at $_repoPath');
  }

  Future<ProcessResult> _run(List<String> args) async {
    final result = await Process.run(
      'git',
      ['-C', _repoPath!, ...args],
    );
    if (result.exitCode != 0) {
      final stderr = result.stderr.toString().trim();
      developer.log('git ${args.join(' ')} failed: $stderr');
      throw GitException(
        'git ${args.first} failed',
        exitCode: result.exitCode,
        stderr: stderr,
      );
    }
    return result;
  }

  String _authedUrl(String repoUrl, String? pat) {
    if (pat == null || pat.isEmpty) return repoUrl;
    final uri = Uri.parse(repoUrl);
    return uri.replace(userInfo: pat).toString();
  }

  @override
  Future<void> clone(String repoUrl, String targetPath, {String? pat}) async {
    final url = _authedUrl(repoUrl, pat);
    final result = await Process.run('git', ['clone', url, targetPath]);
    if (result.exitCode != 0) {
      throw GitException(
        'git clone failed',
        exitCode: result.exitCode,
        stderr: result.stderr.toString().trim(),
      );
    }
    _repoPath = targetPath;
    _initialized = true;
    developer.log('GitService: cloned $repoUrl -> $targetPath');
  }

  @override
  Future<void> pull({String? pat}) async {
    _ensureInitialized();
    try {
      await _run(['pull', '--no-rebase', '--allow-unrelated-histories']);
    } on GitException catch (e) {
      if (e.isConflict) {
        await _resolveConflictsKeepBoth();
      } else {
        rethrow;
      }
    }
  }

  /// Resolve merge conflicts by keeping both versions.
  /// Local version is saved as `<name>-local-<timestamp>.md`,
  /// remote version wins the original filename.
  Future<void> _resolveConflictsKeepBoth() async {
    final result = await Process.run(
      'git',
      ['-C', _repoPath!, 'diff', '--name-only', '--diff-filter=U'],
    );
    final conflicted = result.stdout
        .toString()
        .trim()
        .split('\n')
        .where((f) => f.isNotEmpty)
        .toList();

    for (final file in conflicted) {
      // Save our version as a timestamped copy
      final ours = await Process.run(
        'git',
        ['-C', _repoPath!, 'show', ':2:$file'],
      );
      if (ours.exitCode == 0) {
        final dot = file.lastIndexOf('.');
        final base = dot > 0 ? file.substring(0, dot) : file;
        final ext = dot > 0 ? file.substring(dot) : '';
        final ts = DateTime.now().millisecondsSinceEpoch;
        await File('$_repoPath/$base-local-$ts$ext')
            .writeAsString(ours.stdout.toString());
      }

      // Accept theirs for the original path
      await Process.run(
        'git',
        ['-C', _repoPath!, 'checkout', '--theirs', file],
      );
    }

    // Stage everything and finalize the merge
    await _run(['add', '-A']);
    await _run([
      'commit',
      '-m',
      'Merge: keep both versions of conflicted files',
    ]);
    developer.log(
      'GitService: resolved ${conflicted.length} conflict(s) — kept both versions',
    );
  }

  @override
  Future<void> push({String? pat}) async {
    _ensureInitialized();
    try {
      await _run(['push']);
    } on GitException {
      // First push — set upstream
      await _run(['push', '-u', 'origin', 'main']);
    }
  }

  @override
  Future<void> add(String filePath) async {
    _ensureInitialized();
    await _run(['add', filePath]);
  }

  @override
  Future<void> addAll() async {
    _ensureInitialized();
    await _run(['add', '-A']);
  }

  @override
  Future<void> commit(String message) async {
    _ensureInitialized();
    await _run(['commit', '-m', message]);
  }

  @override
  Future<bool> hasChanges() async {
    _ensureInitialized();
    final result = await Process.run(
      'git',
      ['-C', _repoPath!, 'status', '--porcelain'],
    );
    return result.stdout.toString().trim().isNotEmpty;
  }

  @override
  Future<bool> isGitRepo() async {
    if (_repoPath == null) return false;
    return Directory('$_repoPath/.git').exists();
  }

  @override
  Future<void> initRepo() async {
    _ensureInitialized();
    final result =
        await Process.run('git', ['init', '-b', 'main', _repoPath!]);
    if (result.exitCode != 0) {
      throw GitException(
        'git init failed',
        exitCode: result.exitCode,
        stderr: result.stderr.toString().trim(),
      );
    }
  }

  @override
  Future<void> setRemoteUrl(String url, {String? pat}) async {
    _ensureInitialized();
    final authed = _authedUrl(url, pat);
    final hasOrigin = await hasRemote();
    if (hasOrigin) {
      await _run(['remote', 'set-url', 'origin', authed]);
    } else {
      await _run(['remote', 'add', 'origin', authed]);
    }
  }

  @override
  Future<bool> hasRemote() async {
    _ensureInitialized();
    final result = await Process.run(
      'git',
      ['-C', _repoPath!, 'remote'],
    );
    return result.stdout.toString().trim().isNotEmpty;
  }

  @override
  Future<void> configUser(String name, String email) async {
    _ensureInitialized();
    await _run(['config', 'user.name', name]);
    await _run(['config', 'user.email', email]);
  }

  void _ensureInitialized() {
    if (!_initialized || _repoPath == null) {
      throw GitException('GitService not initialized');
    }
  }
}
