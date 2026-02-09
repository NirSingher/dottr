import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/platform_path.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late SettingsService _service;

  @override
  Future<AppSettings> build() async {
    _service = ref.read(settingsServiceProvider);
    if (kIsWeb) return const AppSettings();
    final journalPath = await getJournalBasePath();
    await _service.initialize(journalPath);
    return _service.loadSettings();
  }

  Future<void> _update(AppSettings settings) async {
    state = AsyncData(settings);
    await _service.saveSettings(settings);
  }

  Future<void> setThemeMode(String mode) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _update(current.copyWith(themeMode: mode));
  }

  Future<void> setAccentColor(int color) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _update(current.copyWith(accentColor: color));
  }

  Future<void> setOnThisDayEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _update(current.copyWith(onThisDayEnabled: enabled));
  }

  Future<void> setOnThisDayTags(List<String> tags) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _update(current.copyWith(onThisDayTags: tags));
  }

  Future<void> setOnThisDayNotificationEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _update(current.copyWith(onThisDayNotificationEnabled: enabled));
  }

  Future<void> setOnThisDayNotificationTime(int hour, int minute) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _update(current.copyWith(
      onThisDayNotificationHour: hour,
      onThisDayNotificationMinute: minute,
    ));
  }
}

// Derived convenience providers so app.dart / settings_screen.dart stay simple
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return settings?.themeModeEnum ?? ThemeMode.system;
});

final accentColorProvider = Provider<Color>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return settings?.accentColorValue ?? const Color(0xFFFFFFFF);
});
