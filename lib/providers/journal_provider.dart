import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/platform_path.dart';
import '../models/journal.dart';
import '../services/journal_service.dart';

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService();
});

final journalProvider =
    AsyncNotifierProvider<JournalNotifier, List<Journal>>(JournalNotifier.new);

/// Currently selected journal for filtering. null = all entries.
final selectedJournalProvider = StateProvider<String?>((ref) => null);

class JournalNotifier extends AsyncNotifier<List<Journal>> {
  late JournalService _journalService;

  @override
  Future<List<Journal>> build() async {
    _journalService = ref.read(journalServiceProvider);
    if (kIsWeb) return [];
    final journalPath = await getJournalBasePath();
    await _journalService.initialize(journalPath);
    return _journalService.loadJournals();
  }

  Future<void> addJournal(Journal journal) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, journal];
    await _journalService.saveJournals(updated);
    state = AsyncData(updated);
  }

  Future<void> updateJournal(int index, Journal journal) async {
    final current = state.valueOrNull ?? [];
    final updated = List<Journal>.from(current);
    updated[index] = journal;
    await _journalService.saveJournals(updated);
    state = AsyncData(updated);
  }

  Future<void> deleteJournal(int index) async {
    final current = state.valueOrNull ?? [];
    final updated = List<Journal>.from(current);
    updated.removeAt(index);
    await _journalService.saveJournals(updated);
    state = AsyncData(updated);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.valueOrNull ?? [];
    final updated = List<Journal>.from(current);
    if (newIndex > oldIndex) newIndex--;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    await _journalService.saveJournals(updated);
    state = AsyncData(updated);
  }
}
