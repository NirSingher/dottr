import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import 'entries_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<AsyncValue<List<Entry>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final entries = ref.watch(entriesProvider);

  if (query.isEmpty) return const AsyncData([]);

  return entries.whenData((list) {
    return list.where((entry) {
      return entry.title.toLowerCase().contains(query) ||
          entry.body.toLowerCase().contains(query) ||
          entry.tags.any((t) => t.toLowerCase().contains(query)) ||
          (entry.mood?.toLowerCase().contains(query) ?? false) ||
          (entry.location?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});
