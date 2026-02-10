import 'dart:developer' as developer;
import 'dart:io';
import 'package:git_on_dart/git_on_dart.dart' as git;
import 'git_service.dart';

/// Git service implementation using git_on_dart (pure Dart).
/// Works on iOS/Android where the git binary is not available.
class GitServiceLibgit implements GitService {
  bool _initialized = false;
  String? _repoPath;
  git.GitRepository? _repo;
  String _userName = 'Dottr';
  String _userEmail = 'dottr@local';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize(String repoPath) async {
    _repoPath = repoPath;
    if (await Directory('$repoPath/.git').exists()) {
      _repo = await git.GitRepository.open(repoPath);
    }
    _initialized = true;
    developer.log('GitServiceLibgit: initialized at $_repoPath');
  }

  git.HttpsCredentials? _credentials(String? pat) {
    if (pat == null || pat.isEmpty) return null;
    return git.HttpsCredentials.token(pat);
  }

  void _ensureInitialized() {
    if (!_initialized || _repoPath == null) {
      throw GitException('GitService not initialized');
    }
  }

  void _ensureRepo() {
    _ensureInitialized();
    if (_repo == null) {
      throw GitException('No git repository open');
    }
  }

  @override
  Future<void> clone(String repoUrl, String targetPath, {String? pat}) async {
    final cloneOp = git.CloneOperation();
    final creds = _credentials(pat);
    final result = await cloneOp.clone(
      url: repoUrl,
      path: targetPath,
      credentials: creds,
    );
    if (!result.success) {
      throw GitException(
        'git clone failed',
        stderr: result.error,
      );
    }
    _repoPath = targetPath;
    _repo = result.repository;
    _initialized = true;
    developer.log('GitServiceLibgit: cloned $repoUrl -> $targetPath');
  }

  @override
  Future<void> pull({String? pat}) async {
    _ensureRepo();
    final pullOp = git.PullOperation(_repo!);
    final creds = _credentials(pat);
    final result = await pullOp.pull('origin', credentials: creds);
    if (!result.success) {
      throw GitException(
        'git pull failed',
        stderr: result.error,
      );
    }
  }

  @override
  Future<void> push({String? pat}) async {
    _ensureRepo();
    final pushOp = git.PushOperation(_repo!);
    final creds = _credentials(pat);
    final result = await pushOp.push('origin', credentials: creds);
    if (!result.success) {
      throw GitException(
        'git push failed',
        stderr: result.error,
      );
    }
  }

  @override
  Future<void> add(String filePath) async {
    _ensureRepo();
    final addOp = git.AddOperation(_repo!);
    await addOp.add([filePath]);
  }

  @override
  Future<void> addAll() async {
    _ensureRepo();
    final addOp = git.AddOperation(_repo!);
    await addOp.addAll();
  }

  @override
  Future<void> commit(String message) async {
    _ensureRepo();
    final commitOp = git.CommitOperation(_repo!);
    await commitOp.commit(
      message,
      author: git.GitAuthor(
        name: _userName,
        email: _userEmail,
      ),
    );
  }

  @override
  Future<bool> hasChanges() async {
    _ensureRepo();
    final statusOp = git.StatusOperation(_repo!);
    final status = await statusOp.status();
    return !status.isClean;
  }

  @override
  Future<bool> isGitRepo() async {
    if (_repoPath == null) return false;
    return Directory('$_repoPath/.git').exists();
  }

  @override
  Future<void> initRepo() async {
    _ensureInitialized();
    _repo = await git.GitRepository.init(_repoPath!);
    developer.log('GitServiceLibgit: init repo at $_repoPath');
  }

  @override
  Future<void> setRemoteUrl(String url, {String? pat}) async {
    _ensureRepo();
    final remoteManager = git.RemoteManager(_repo!.gitDir);
    final hasOrigin = await hasRemote();
    if (hasOrigin) {
      await remoteManager.setUrl('origin', url);
    } else {
      await remoteManager.addRemote('origin', url);
    }
  }

  @override
  Future<bool> hasRemote() async {
    _ensureRepo();
    try {
      final remoteManager = git.RemoteManager(_repo!.gitDir);
      final remotes = await remoteManager.listRemotes();
      return remotes.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> configUser(String name, String email) async {
    _userName = name;
    _userEmail = email;
    // Also persist to git config if repo is open
    if (_repo != null) {
      try {
        final config = await _repo!.config;
        config.set('user', 'name', name);
        config.set('user', 'email', email);
        await config.save();
      } catch (_) {
        // Config write failure is non-fatal — in-memory values still work
      }
    }
  }
}
