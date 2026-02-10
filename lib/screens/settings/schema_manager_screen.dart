import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottr_theme.dart';
import '../../models/property_schema.dart';
import '../../providers/schema_provider.dart';

class SchemaManagerScreen extends ConsumerWidget {
  const SchemaManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final schemasAsync = ref.watch(schemaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Properties'),
      ),
      body: schemasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (schemas) {
          if (schemas.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No custom properties',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add fields like "weather", "energy", etc.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schemas.length,
            itemBuilder: (context, index) {
              final schema = schemas[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BrutalistCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schema.name,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                BrutalistChip(label: schema.type.name),
                                if (schema.autoAdd) ...[
                                  const SizedBox(width: 6),
                                  BrutalistChip(label: 'auto-add'),
                                ],
                                if (schema.required) ...[
                                  const SizedBox(width: 6),
                                  BrutalistChip(label: 'required'),
                                ],
                              ],
                            ),
                            if (schema.options != null &&
                                schema.options!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Options: ${schema.options!.join(', ')}',
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
                        onPressed: () => _confirmDelete(context, ref, index),
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
        onPressed: () => _showAddDialog(context, ref),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final optionsController = TextEditingController();
    var selectedType = PropertyType.text;
    var autoAdd = false;

    final result = await showDialog<PropertySchema>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: const Text('Add Property'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'e.g. weather',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Type', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: PropertyType.values.map((type) {
                      final selected = type == selectedType;
                      return ChoiceChip(
                        label: Text(type.name),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => selectedType = type),
                      );
                    }).toList(),
                  ),
                  if (selectedType == PropertyType.select ||
                      selectedType == PropertyType.multiSelect) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: optionsController,
                      decoration: const InputDecoration(
                        labelText: 'Options (comma-separated)',
                        hintText: 'sunny, cloudy, rainy',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Auto-add to new entries'),
                    value: autoAdd,
                    onChanged: (v) =>
                        setState(() => autoAdd = v ?? false),
                    contentPadding: EdgeInsets.zero,
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
                  List<String>? options;
                  if (selectedType == PropertyType.select ||
                      selectedType == PropertyType.multiSelect) {
                    options = optionsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                  }
                  Navigator.pop(
                    context,
                    PropertySchema(
                      name: name,
                      type: selectedType,
                      options: options,
                      autoAdd: autoAdd,
                    ),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      await ref.read(schemaProvider.notifier).addSchema(result);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete property?'),
        content: const Text(
          'This removes the schema. Existing entry data won\'t be deleted.',
        ),
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
      await ref.read(schemaProvider.notifier).deleteSchema(index);
    }
  }
}
