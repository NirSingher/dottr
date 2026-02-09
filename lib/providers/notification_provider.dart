import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_config.dart';
import '../services/notification_service.dart';
import '../services/notification_storage_service.dart';

final notificationStorageProvider = Provider<NotificationStorageService>((ref) {
  return NotificationStorageService();
});

final notificationProvider = AsyncNotifierProvider<NotificationNotifier,
    List<NotificationConfig>>(NotificationNotifier.new);

class NotificationNotifier extends AsyncNotifier<List<NotificationConfig>> {
  late NotificationStorageService _storage;

  @override
  Future<List<NotificationConfig>> build() async {
    _storage = ref.read(notificationStorageProvider);
    return _storage.loadConfigs();
  }

  Future<void> add(NotificationConfig config) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, config];
    await _storage.saveConfigs(updated);
    await NotificationService.instance.scheduleNotification(config);
    state = AsyncData(updated);
  }

  Future<void> addNew({
    required String label,
    required int hour,
    required int minute,
    required List<int> daysOfWeek,
    String? templateId,
  }) async {
    final config = NotificationConfig(
      id: const Uuid().v4(),
      label: label,
      hour: hour,
      minute: minute,
      daysOfWeek: daysOfWeek,
      templateId: templateId,
    );
    await add(config);
  }

  Future<void> updateConfig(String id, NotificationConfig config) async {
    final current = state.valueOrNull ?? [];
    final updated = current.map((c) => c.id == id ? config : c).toList();
    await _storage.saveConfigs(updated);
    await NotificationService.instance.scheduleNotification(config);
    state = AsyncData(updated);
  }

  Future<void> toggle(String id) async {
    final current = state.valueOrNull ?? [];
    final idx = current.indexWhere((c) => c.id == id);
    if (idx < 0) return;
    final toggled = current[idx].copyWith(enabled: !current[idx].enabled);
    await updateConfig(id, toggled);
  }

  Future<void> delete(String id) async {
    final current = state.valueOrNull ?? [];
    final config = current.firstWhere((c) => c.id == id);
    await NotificationService.instance.cancelNotification(config);
    final updated = current.where((c) => c.id != id).toList();
    await _storage.saveConfigs(updated);
    state = AsyncData(updated);
  }

  /// Re-schedule all enabled notifications (call after app launch).
  Future<void> rescheduleAll() async {
    final configs = state.valueOrNull ?? [];
    for (final config in configs) {
      if (config.enabled) {
        await NotificationService.instance.scheduleNotification(config);
      }
    }
  }
}
