import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import 'entries_provider.dart';
import 'journal_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<AsyncValue<List<Entry>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final selectedJournal = ref.watch(selectedJournalProvider);
  final entries = ref.watch(entriesProvider);

  if (query.isEmpty) return const AsyncData([]);

  return entries.whenData((list) {
    var filtered = list;
    if (selectedJournal != null) {
      filtered = filtered.where((e) => e.journal == selectedJournal).toList();
    }
    return filtered.where((entry) {
      return entry.title.toLowerCase().contains(query) ||
          entry.body.toLowerCase().contains(query) ||
          entry.tags.any((t) => t.toLowerCase().contains(query)) ||
          (entry.mood?.toLowerCase().contains(query) ?? false) ||
          (entry.location?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});
