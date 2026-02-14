import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/dottr_theme.dart';
import '../providers/entries_provider.dart';
import '../providers/journal_provider.dart';

class JournalDrawer extends ConsumerWidget {
  const JournalDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final journalsAsync = ref.watch(journalProvider);
    final entriesAsync = ref.watch(entriesProvider);
    final selectedJournal = ref.watch(selectedJournalProvider);

    final journals = journalsAsync.valueOrNull ?? [];
    final entries = entriesAsync.valueOrNull ?? [];

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Journals',
                style: theme.textTheme.headlineSmall,
              ),
            ),

            // All Entries
            _JournalTile(
              name: 'All Entries',
              count: entries.length,
              selected: selectedJournal == null,
              onTap: () {
                ref.read(selectedJournalProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),

            const Divider(),

            // Journal list
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: journals.map((journal) {
                  final count =
                      entries.where((e) => e.journal == journal.name).length;
                  return _JournalTile(
                    name: journal.name,
                    color: journal.color,
                    count: count,
                    selected: selectedJournal == journal.name,
                    onTap: () {
                      ref.read(selectedJournalProvider.notifier).state =
                          journal.name;
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),

            const Divider(),

            // Manage Journals link
            ListTile(
              leading: Icon(Icons.settings_outlined, color: colors.muted),
              title: Text(
                'Manage Journals',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.muted,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings/journals');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalTile extends StatelessWidget {
  final String name;
  final Color? color;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _JournalTile({
    required this.name,
    this.color,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;

    return ListTile(
      leading: color != null
          ? Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1.5,
                ),
              ),
            )
          : const Icon(Icons.list, size: 16),
      title: Text(
        name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      trailing: Text(
        '$count',
        style: theme.textTheme.bodySmall?.copyWith(color: colors.muted),
      ),
      selected: selected,
      selectedTileColor: theme.colorScheme.secondary.withAlpha(30),
      onTap: onTap,
    );
  }
}
