class GitConfig {
  static const repoUrl = String.fromEnvironment(
    'GIT_REPO_URL',
    defaultValue: '',
  );
  static const pat = String.fromEnvironment('GIT_PAT', defaultValue: '');

  static bool get isConfigured => repoUrl.isNotEmpty && pat.isNotEmpty;
}
