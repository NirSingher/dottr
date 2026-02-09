import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/platform_path.dart';
import '../models/entry.dart';
import '../services/file_service.dart';
import '../services/file_service_impl.dart';

final fileServiceProvider = Provider<FileService>((ref) {
  return FileServiceImpl();
});

final entriesProvider =
    AsyncNotifierProvider<EntriesNotifier, List<Entry>>(EntriesNotifier.new);

class EntriesNotifier extends AsyncNotifier<List<Entry>> {
  late FileService _fileService;

  @override
  Future<List<Entry>> build() async {
    _fileService = ref.read(fileServiceProvider);
    if (kIsWeb) return []; // No filesystem on web — return empty for UI preview
    final journalPath = await getJournalBasePath();
    await _fileService.initialize(journalPath);
    return _fileService.listEntries();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fileService.listEntries());
  }

  Future<String> saveEntry(Entry entry) async {
    final filePath = await _fileService.writeEntry(
      entry.copyWith(updatedAt: DateTime.now()),
    );
    await refresh();
    return filePath;
  }

  Future<void> deleteEntry(String filePath) async {
    await _fileService.deleteEntry(filePath);
    await refresh();
  }
}

final filteredEntriesProvider = Provider.family<AsyncValue<List<Entry>>, String?>(
  (ref, tag) {
    final entries = ref.watch(entriesProvider);
    if (tag == null || tag.isEmpty) return entries;
    return entries.whenData(
      (list) => list.where((e) => e.tags.contains(tag)).toList(),
    );
  },
);
