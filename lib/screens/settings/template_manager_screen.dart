import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottl_theme.dart';
import '../../models/template.dart';
import '../../providers/template_provider.dart';

class TemplateManagerScreen extends ConsumerWidget {
  const TemplateManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final templatesAsync = ref.watch(templateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No templates',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create templates to quick-start entries',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ],
              ),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(templateProvider.notifier).reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final template = templates[index];
              return Padding(
                key: ValueKey(template.id),
                padding: const EdgeInsets.only(bottom: 12),
                child: BrutalistCard(
                  onTap: () => _showEditDialog(context, ref, index, template),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: template.color,
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 1.5,
                          ),
                          borderRadius:
                              BorderRadius.circular(DottrTheme.cardRadius),
                        ),
                        child: Icon(
                          template.icon,
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
                              template.name,
                              style: theme.textTheme.titleMedium,
                            ),
                            if (template.tags.isNotEmpty ||
                                template.mood != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (template.mood != null)
                                    BrutalistChip(label: template.mood!),
                                  if (template.mood != null &&
                                      template.tags.isNotEmpty)
                                    const SizedBox(width: 6),
                                  ...template.tags
                                      .take(3)
                                      .map((t) => Padding(
                                            padding:
                                                const EdgeInsets.only(right: 4),
                                            child: BrutalistChip(label: t),
                                          )),
                                  if (template.tags.length > 3)
                                    BrutalistChip(
                                      label: '+${template.tags.length - 3}',
                                    ),
                                ],
                              ),
                            ],
                            if (template.body.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                template.body.split('\n').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () =>
                            _confirmDelete(context, ref, index, template.name),
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
    EntryTemplate? existing,
  ) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final tagsController =
        TextEditingController(text: existing?.tags.join(', ') ?? '');
    final bodyController = TextEditingController(text: existing?.body ?? '');
    final moodController = TextEditingController(text: existing?.mood ?? '');
    var selectedColor = existing?.color ?? const Color(0xFFFFDE59);
    var selectedIcon = existing?.icon ?? Icons.description_outlined;

    final colorOptions = [
      const Color(0xFFFFDE59), // yellow
      const Color(0xFF5BC0EB), // blue
      const Color(0xFFFE6D73), // pink
      const Color(0xFF7AE582), // green
      const Color(0xFFE0E0E0), // gray
      const Color(0xFFFFB347), // orange
      const Color(0xFFCDB4DB), // lavender
    ];

    final iconOptions = [
      Icons.description_outlined,
      Icons.wb_sunny_outlined,
      Icons.nightlight_outlined,
      Icons.work_outline,
      Icons.favorite_outline,
      Icons.flag_outlined,
      Icons.star_outline,
      Icons.check_circle_outline,
    ];

    final result = await showDialog<EntryTemplate>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: Text(index != null ? 'Edit Template' : 'New Template'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'e.g. Morning Check-in',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Icon', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: iconOptions.map((icon) {
                      final selected = icon == selectedIcon;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIcon = icon),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline,
                              width: selected
                                  ? DottrTheme.borderWidth
                                  : 1,
                            ),
                            borderRadius:
                                BorderRadius.circular(DottrTheme.cardRadius),
                            color: selected
                                ? theme.colorScheme.secondary
                                : null,
                          ),
                          child: Icon(icon, size: 20),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Color', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colorOptions.map((color) {
                      final selected = color.toARGB32() == selectedColor.toARGB32();
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: moodController,
                    decoration: const InputDecoration(
                      labelText: 'Default mood (emoji)',
                      hintText: 'e.g. \u{1F60A}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Default tags (comma-separated)',
                      hintText: 'journal, morning',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Body scaffold',
                      hintText: '## How am I feeling?\n\n## Grateful for\n\n',
                    ),
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
                  final tags = tagsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  final mood = moodController.text.trim().isEmpty
                      ? null
                      : moodController.text.trim();
                  Navigator.pop(
                    context,
                    EntryTemplate(
                      id: existing?.id ?? const Uuid().v4(),
                      name: name,
                      icon: selectedIcon,
                      color: selectedColor,
                      tags: tags,
                      mood: mood,
                      customProperties: existing?.customProperties ?? const {},
                      body: bodyController.text,
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
        await ref.read(templateProvider.notifier).updateTemplate(index, result);
      } else {
        await ref.read(templateProvider.notifier).addTemplate(result);
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int index,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete template?'),
        content: Text('Remove "$name"? This won\'t affect existing entries.'),
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
      await ref.read(templateProvider.notifier).deleteTemplate(index);
    }
  }
}
