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
}
