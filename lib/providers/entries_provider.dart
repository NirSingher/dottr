import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/constants.dart';
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
    final dir = await getApplicationDocumentsDirectory();
    final journalPath = p.join(dir.path, Constants.journalDirName);
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
