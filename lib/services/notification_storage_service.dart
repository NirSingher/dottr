import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_config.dart';

class NotificationStorageService {
  static const _key = 'dottr_notification_configs';

  Future<List<NotificationConfig>> loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => NotificationConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveConfigs(List<NotificationConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(configs.map((c) => c.toJson()).toList());
    await prefs.setString(_key, json);
  }
}
