import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottr_theme.dart';
import '../../models/journal.dart';
import '../../providers/entries_provider.dart';
import '../../providers/journal_provider.dart';

class JournalManagerScreen extends ConsumerWidget {
  const JournalManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final journalsAsync = ref.watch(journalProvider);
    final entriesAsync = ref.watch(entriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journals'),
      ),
      body: journalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (journals) {
          if (journals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No journals',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create journals to organize your entries',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ],
              ),
            );
          }

          final entries = entriesAsync.valueOrNull ?? [];

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: journals.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(journalProvider.notifier).reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final journal = journals[index];
              final entryCount =
                  entries.where((e) => e.journal == journal.name).length;

              return Padding(
                key: ValueKey(journal.id),
                padding: const EdgeInsets.only(bottom: 12),
                child: BrutalistCard(
                  onTap: () =>
                      _showEditDialog(context, ref, index, journal),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: journal.color,
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 1.5,
                          ),
                          borderRadius:
                              BorderRadius.circular(DottrTheme.cardRadius),
                        ),
                        child: const Icon(
                          Icons.book_outlined,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              journal.name,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$entryCount ${entryCount == 1 ? 'entry' : 'entries'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () => _confirmDelete(
                            context, ref, index, journal.name, entryCount),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_handle,
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: BrutalistFAB(
        icon: Icons.add,
        onPressed: () => _showEditDialog(context, ref, null, null),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    int? index,
    Journal? existing,
  ) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    var selectedColor = existing?.color ?? const Color(0xFFFFDE59);

    const colorOptions = [
      Color(0xFFFFDE59), // yellow
      Color(0xFF5BC0EB), // blue
      Color(0xFFFE6D73), // pink
      Color(0xFF7AE582), // green
      Color(0xFFE0E0E0), // gray
      Color(0xFFFFB347), // orange
      Color(0xFFCDB4DB), // lavender
    ];

    final result = await showDialog<Journal>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: Text(index != null ? 'Edit Journal' : 'New Journal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'e.g. Work, Personal',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Color', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colorOptions.map((color) {
                      final selected =
                          color.toARGB32() == selectedColor.toARGB32();
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: theme.colorScheme.outline,
                              width: selected
                                  ? DottrTheme.borderWidth
                                  : 1,
                            ),
                            borderRadius:
                                BorderRadius.circular(DottrTheme.cardRadius),
                          ),
                          child: selected
                              ? const Icon(Icons.check, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  // Validate no duplicate names
                  final journals =
                      ref.read(journalProvider).valueOrNull ?? [];
                  final duplicate = journals.any((j) =>
                      j.name.toLowerCase() == name.toLowerCase() &&
                      j.id != (existing?.id ?? ''));
                  if (duplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('A journal with that name already exists')),
                    );
                    return;
                  }

                  Navigator.pop(
                    context,
                    Journal(
                      id: existing?.id ?? const Uuid().v4(),
                      name: name,
                      color: selectedColor,
                    ),
                  );
                },
                child: Text(index != null ? 'Save' : 'Create'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      if (index != null) {
        await ref.read(journalProvider.notifier).updateJournal(index, result);
      } else {
        await ref.read(journalProvider.notifier).addJournal(result);
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int index,
    String name,
    int entryCount,
  ) async {
    final message = entryCount > 0
        ? 'Remove "$name"? $entryCount ${entryCount == 1 ? 'entry' : 'entries'} will become journal-less.'
        : 'Remove "$name"?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete journal?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(journalProvider.notifier).deleteJournal(index);
    }
  }
}
