import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/brutalist_components.dart';
import '../../../core/theme/dottl_theme.dart';
import '../../../models/property_schema.dart';
import '../../../providers/editor_provider.dart';
import '../../../providers/schema_provider.dart';

class PropertiesForm extends ConsumerStatefulWidget {
  const PropertiesForm({super.key});

  @override
  ConsumerState<PropertiesForm> createState() => _PropertiesFormState();
}

class _PropertiesFormState extends ConsumerState<PropertiesForm> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editorState = ref.watch(editorProvider);
    final entry = editorState.entry;
    if (entry == null) return const SizedBox.shrink();

    final schemasAsync = ref.watch(schemaProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date
        _PropertyRow(
          label: 'Date',
          child: GestureDetector(
            onTap: () => _pickDate(context),
            child: BrutalistChip(
              label: DateFormat('MMM d, yyyy').format(entry.date),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Time
        _PropertyRow(
          label: 'Time',
          child: GestureDetector(
            onTap: () => _pickTime(context),
            child: BrutalistChip(
              label: entry.time ?? DateFormat('HH:mm').format(DateTime.now()),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Mood
        _PropertyRow(
          label: 'Mood',
          child: Wrap(
            spacing: 8,
            children: ['😊', '😐', '😔', '🔥', '😴'].map((mood) {
              final selected = entry.mood == mood;
              return GestureDetector(
                onTap: () => ref.read(editorProvider.notifier).updateMood(
                      selected ? null : mood,
                    ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.secondary
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(DottrTheme.cardRadius),
                    border: selected
                        ? Border.all(
                            color: theme.colorScheme.outline,
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Text(mood, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Tags
        _PropertyRow(
          label: 'Tags',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: entry.tags.map((tag) {
                    return BrutalistChip(
                      label: '#$tag',
                      onDelete: () {
                        final tags = List<String>.from(entry.tags)
                          ..remove(tag);
                        ref.read(editorProvider.notifier).updateTags(tags);
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    hintText: 'Add tag...',
                    hintStyle: theme.textTheme.bodySmall,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    final tag = value.trim();
                    if (tag.isNotEmpty && !entry.tags.contains(tag)) {
                      ref.read(editorProvider.notifier).updateTags(
                        [...entry.tags, tag],
                      );
                    }
                    _tagController.clear();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Location
        BrutalistTextField(
          labelText: 'Location',
          hintText: 'Where are you?',
          controller: TextEditingController(text: entry.location ?? ''),
          onChanged: (value) =>
              ref.read(editorProvider.notifier).updateLocation(
                    value.isEmpty ? null : value,
                  ),
        ),
        const SizedBox(height: 12),

        // Custom properties from schema
        schemasAsync.whenData((schemas) {
          if (schemas.isEmpty) return const SizedBox.shrink();
          return Column(
            children: schemas
                .where((s) => s.autoAdd || entry.customProperties.containsKey(s.name))
                .map((schema) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CustomPropertyField(schema: schema),
                    ))
                .toList(),
          );
        }).valueOrNull ?? const SizedBox.shrink(),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final entry = ref.read(editorProvider).entry;
    if (entry == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: entry.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ref.read(editorProvider.notifier).loadEntry(
            entry.copyWith(date: picked),
          );
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final entry = ref.read(editorProvider).entry;
    if (entry == null) return;
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(editorProvider.notifier).updateTime(timeStr);
    }
  }
}

class _PropertyRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _PropertyRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _CustomPropertyField extends ConsumerWidget {
  final PropertySchema schema;

  const _CustomPropertyField({required this.schema});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(editorProvider).entry;
    if (entry == null) return const SizedBox.shrink();
    final value = entry.customProperties[schema.name];

    switch (schema.type) {
      case PropertyType.text:
        return BrutalistTextField(
          labelText: schema.name,
          controller: TextEditingController(text: value?.toString() ?? ''),
          onChanged: (v) =>
              ref.read(editorProvider.notifier).updateCustomProperty(
                    schema.name,
                    v,
                  ),
        );
      case PropertyType.number:
        return BrutalistTextField(
          labelText: schema.name,
          controller: TextEditingController(text: value?.toString() ?? ''),
          onChanged: (v) =>
              ref.read(editorProvider.notifier).updateCustomProperty(
                    schema.name,
                    num.tryParse(v),
                  ),
        );
      case PropertyType.boolean:
        return _PropertyRow(
          label: schema.name,
          child: Switch(
            value: value == true,
            onChanged: (v) =>
                ref.read(editorProvider.notifier).updateCustomProperty(
                      schema.name,
                      v,
                    ),
          ),
        );
      case PropertyType.select:
        return _PropertyRow(
          label: schema.name,
          child: Wrap(
            spacing: 6,
            children: (schema.options ?? []).map((option) {
              final selected = value == option;
              return BrutalistChip(
                label: option,
                color: selected
                    ? Theme.of(context).colorScheme.secondary
                    : null,
                onTap: () =>
                    ref.read(editorProvider.notifier).updateCustomProperty(
                          schema.name,
                          selected ? null : option,
                        ),
              );
            }).toList(),
          ),
        );
      case PropertyType.multiSelect:
        final selectedList = (value as List?)?.cast<String>() ?? [];
        return _PropertyRow(
          label: schema.name,
          child: Wrap(
            spacing: 6,
            children: (schema.options ?? []).map((option) {
              final selected = selectedList.contains(option);
              return BrutalistChip(
                label: option,
                color: selected
                    ? Theme.of(context).colorScheme.secondary
                    : null,
                onTap: () {
                  final updated = List<String>.from(selectedList);
                  if (selected) {
                    updated.remove(option);
                  } else {
                    updated.add(option);
                  }
                  ref.read(editorProvider.notifier).updateCustomProperty(
                        schema.name,
                        updated,
                      );
                },
              );
            }).toList(),
          ),
        );
      case PropertyType.date:
        return _PropertyRow(
          label: schema.name,
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(value?.toString() ?? '') ??
                    DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                ref.read(editorProvider.notifier).updateCustomProperty(
                      schema.name,
                      picked.toIso8601String().split('T').first,
                    );
              }
            },
            child: BrutalistChip(
              label: value?.toString() ?? 'Select date',
            ),
          ),
        );
    }
  }
}
