import 'dart:developer' as developer;
import 'git_service.dart';

/// Placeholder Git service implementation.
///
/// Full implementation requires validating git_on_dart or dart_git
/// on iOS simulator. This stub allows the app to build and run
/// with local-only file storage until the Git spike is completed.
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

  @override
  Future<void> clone(String repoUrl, String targetPath, {String? pat}) async {
    developer.log('GitService: clone $repoUrl -> $targetPath (stub)');
    // TODO: Implement with git_on_dart or dart_git after spike
  }

  @override
  Future<void> pull({String? pat}) async {
    developer.log('GitService: pull (stub)');
  }

  @override
  Future<void> push({String? pat}) async {
    developer.log('GitService: push (stub)');
  }

  @override
  Future<void> add(String filePath) async {
    developer.log('GitService: add $filePath (stub)');
  }

  @override
  Future<void> addAll() async {
    developer.log('GitService: add all (stub)');
  }

  @override
  Future<void> commit(String message) async {
    developer.log('GitService: commit "$message" (stub)');
  }

  @override
  Future<bool> hasChanges() async {
    return false;
  }
}
