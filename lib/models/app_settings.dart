import 'package:flutter/material.dart';

class AppSettings {
  final String themeMode; // 'system', 'light', 'dark'
  final int accentColor;

  // Git sync
  final String gitRepoUrl;

  // On This Day settings (Feature 4)
  final bool onThisDayEnabled;
  final List<String> onThisDayTags;
  final bool onThisDayNotificationEnabled;
  final int onThisDayNotificationHour;
  final int onThisDayNotificationMinute;

  const AppSettings({
    this.themeMode = 'system',
    this.accentColor = 0xFFFFFFFF,
    this.gitRepoUrl = '',
    this.onThisDayEnabled = true,
    this.onThisDayTags = const [],
    this.onThisDayNotificationEnabled = false,
    this.onThisDayNotificationHour = 9,
    this.onThisDayNotificationMinute = 0,
  });

  ThemeMode get themeModeEnum => switch (themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Color get accentColorValue => Color(accentColor);

  AppSettings copyWith({
    String? themeMode,
    int? accentColor,
    String? gitRepoUrl,
    bool? onThisDayEnabled,
    List<String>? onThisDayTags,
    bool? onThisDayNotificationEnabled,
    int? onThisDayNotificationHour,
    int? onThisDayNotificationMinute,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      gitRepoUrl: gitRepoUrl ?? this.gitRepoUrl,
      onThisDayEnabled: onThisDayEnabled ?? this.onThisDayEnabled,
      onThisDayTags: onThisDayTags ?? this.onThisDayTags,
      onThisDayNotificationEnabled:
          onThisDayNotificationEnabled ?? this.onThisDayNotificationEnabled,
      onThisDayNotificationHour:
          onThisDayNotificationHour ?? this.onThisDayNotificationHour,
      onThisDayNotificationMinute:
          onThisDayNotificationMinute ?? this.onThisDayNotificationMinute,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'accentColor': accentColor,
        'gitRepoUrl': gitRepoUrl,
        'onThisDayEnabled': onThisDayEnabled,
        'onThisDayTags': onThisDayTags,
        'onThisDayNotificationEnabled': onThisDayNotificationEnabled,
        'onThisDayNotificationHour': onThisDayNotificationHour,
        'onThisDayNotificationMinute': onThisDayNotificationMinute,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] as String? ?? 'system',
      accentColor: json['accentColor'] as int? ?? 0xFFFFFFFF,
      gitRepoUrl: json['gitRepoUrl'] as String? ?? '',
      onThisDayEnabled: json['onThisDayEnabled'] as bool? ?? true,
      onThisDayTags:
          (json['onThisDayTags'] as List?)?.cast<String>() ?? const [],
      onThisDayNotificationEnabled:
          json['onThisDayNotificationEnabled'] as bool? ?? false,
      onThisDayNotificationHour:
          json['onThisDayNotificationHour'] as int? ?? 9,
      onThisDayNotificationMinute:
          json['onThisDayNotificationMinute'] as int? ?? 0,
    );
  }
}
