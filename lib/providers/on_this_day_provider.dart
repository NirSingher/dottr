import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import '../providers/entries_provider.dart';
import '../providers/settings_provider.dart';
import '../services/on_this_day_service.dart';

final onThisDayProvider = Provider<List<Entry>>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (settings == null || !settings.onThisDayEnabled) return [];

  final entriesAsync = ref.watch(entriesProvider);
  final entries = entriesAsync.valueOrNull ?? [];
  if (entries.isEmpty) return [];

  return OnThisDayService.findEntries(
    entries,
    DateTime.now(),
    tagFilter: settings.onThisDayTags,
  );
});
