class Constants {
  static const String journalDirName = 'journal';
  static const String schemaDirName = '.dottr';
  static const String schemaFileName = 'schemas.yaml';
  static const String templateFileName = 'templates.yaml';
  static const String settingsFileName = 'settings.json';
  static const Duration autoSaveDelay = Duration(seconds: 3);
  static const Duration syncPollInterval = Duration(seconds: 60);
  static const Duration syncDebounce = Duration(minutes: 5);
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm';
  static const String conflictSuffix = '.conflict-';
}
