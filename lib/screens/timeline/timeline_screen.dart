import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/brutalist_components.dart';
import '../../models/entry.dart';
import '../../providers/entries_provider.dart';
import '../editor/widgets/template_picker.dart';
import 'widgets/entry_card.dart';
import 'widgets/month_header.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('dottr'),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Failed to load entries', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(err.toString(), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return _EmptyState(
              onCreateFirst: () => context.push('/editor'),
            );
          }
          return _EntryList(entries: entries);
        },
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () async {
          final template = await showTemplatePicker(context);
          if (template != null && context.mounted) {
            context.push('/editor?template=${Uri.encodeComponent(template.id)}');
          }
        },
        child: BrutalistFAB(
          icon: Icons.add,
          onPressed: () => context.push('/editor'),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateFirst;

  const _EmptyState({required this.onCreateFirst});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No entries yet',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to write your first journal entry',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
            const SizedBox(height: 24),
            BrutalistButton(
              label: 'Write something',
              icon: Icons.edit,
              onPressed: onCreateFirst,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryList extends ConsumerWidget {
  final List<Entry> entries;

  const _EntryList({required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group entries by year-month
    final grouped = <String, List<Entry>>{};
    for (final entry in entries) {
      final key = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    final months = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: () => ref.read(entriesProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: months.length,
        itemBuilder: (context, monthIndex) {
          final monthKey = months[monthIndex];
          final monthEntries = grouped[monthKey]!;
          final sampleDate = monthEntries.first.date;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonthHeader(date: sampleDate),
              ...monthEntries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: EntryCard(
                      entry: entry,
                      onTap: () {
                        if (entry.filePath != null) {
                          context.push(
                            '/viewer?path=${Uri.encodeComponent(entry.filePath!)}',
                          );
                        }
                      },
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
