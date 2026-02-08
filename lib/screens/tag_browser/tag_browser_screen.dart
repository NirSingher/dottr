import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottl_theme.dart';
import '../../providers/entries_provider.dart';
import '../timeline/widgets/entry_card.dart';

final _selectedTagProvider = StateProvider<String?>((ref) => null);

class TagBrowserScreen extends ConsumerWidget {
  const TagBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final entriesAsync = ref.watch(entriesProvider);
    final selectedTag = ref.watch(_selectedTagProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          if (selectedTag != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () =>
                  ref.read(_selectedTagProvider.notifier).state = null,
            ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (entries) {
          // Collect all tags with counts
          final tagCounts = <String, int>{};
          for (final entry in entries) {
            for (final tag in entry.tags) {
              tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
            }
          }

          if (tagCounts.isEmpty) {
            return Center(
              child: Text(
                'No tags yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(120),
                ),
              ),
            );
          }

          final sortedTags = tagCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          if (selectedTag != null) {
            // Show filtered entries
            final filtered = entries
                .where((e) => e.tags.contains(selectedTag))
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      BrutalistChip(
                        label: '#$selectedTag',
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${filtered.length} entries',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: EntryCard(
                          entry: filtered[index],
                          onTap: () {
                            final fp = filtered[index].filePath;
                            if (fp != null) {
                              context.push(
                                '/viewer?path=${Uri.encodeComponent(fp)}',
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Show tag cloud
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sortedTags.map((entry) {
                return BrutalistButton(
                  label: '#${entry.key}  (${entry.value})',
                  compact: true,
                  color: theme.colorScheme.surface,
                  onPressed: () => ref
                      .read(_selectedTagProvider.notifier)
                      .state = entry.key,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
