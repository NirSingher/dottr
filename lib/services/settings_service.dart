import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../core/constants.dart';
import '../models/app_settings.dart';

class SettingsService {
  late String _basePath;

  Future<void> initialize(String basePath) async {
    _basePath = basePath;
    final dir = Directory(p.join(_basePath, Constants.schemaDirName));
    await dir.create(recursive: true);
  }

  String get _settingsFilePath =>
      p.join(_basePath, Constants.schemaDirName, Constants.settingsFileName);

  Future<AppSettings> loadSettings() async {
    final file = File(_settingsFilePath);
    if (!await file.exists()) return const AppSettings();
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final file = File(_settingsFilePath);
    await file.parent.create(recursive: true);
    final content = const JsonEncoder.withIndent('  ').convert(settings.toJson());
    await file.writeAsString(content);
  }
}
