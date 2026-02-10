import 'dart:io';

abstract class GitService {
  Future<void> clone(String repoUrl, String targetPath, {String? pat});
  Future<void> pull({String? pat});
  Future<void> push({String? pat});
  Future<void> add(String filePath);
  Future<void> addAll();
  Future<void> commit(String message);
  Future<bool> hasChanges();
  Future<void> initialize(String repoPath);
  bool get isInitialized;

  Future<bool> isGitRepo();
  Future<void> initRepo();
  Future<void> setRemoteUrl(String url, {String? pat});
  Future<bool> hasRemote();
  Future<void> configUser(String name, String email);

  static Future<bool> isGitAvailable() async {
    try {
      final result = await Process.run('which', ['git']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}

class GitException implements Exception {
  final String message;
  final int? exitCode;
  final String? stderr;

  GitException(this.message, {this.exitCode, this.stderr});

  bool get isConflict =>
      stderr != null && stderr!.toLowerCase().contains('conflict');

  bool get isAuthFailure =>
      stderr != null &&
      (stderr!.contains('Authentication failed') ||
          stderr!.contains('could not read Username') ||
          stderr!.contains('authentication'));

  @override
  String toString() => 'GitException: $message (exit $exitCode)';
}
