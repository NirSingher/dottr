import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottr_theme.dart';
import '../../providers/notification_provider.dart';
import '../../providers/template_provider.dart';

class NotificationEditScreen extends ConsumerStatefulWidget {
  final String? configId;

  const NotificationEditScreen({super.key, this.configId});

  @override
  ConsumerState<NotificationEditScreen> createState() =>
      _NotificationEditScreenState();
}

class _NotificationEditScreenState
    extends ConsumerState<NotificationEditScreen> {
  late TextEditingController _labelController;
  late int _hour;
  late int _minute;
  late Set<int> _selectedDays;
  String? _templateId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: 'Daily journal');
    _hour = 9;
    _minute = 0;
    _selectedDays = {1, 2, 3, 4, 5, 6, 7};

    if (widget.configId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExisting();
      });
    }
  }

  void _loadExisting() {
    final configs = ref.read(notificationProvider).valueOrNull ?? [];
    final match = configs.where((c) => c.id == widget.configId);
    if (match.isEmpty) return;
    final config = match.first;
    setState(() {
      _isEditing = true;
      _labelController.text = config.label;
      _hour = config.hour;
      _minute = config.minute;
      _selectedDays = config.daysOfWeek.toSet();
      _templateId = config.templateId;
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templatesAsync = ref.watch(templateProvider);

    final timeStr =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reminder' : 'New Reminder'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteConfig,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Label
          BrutalistTextField(
            labelText: 'Label',
            hintText: 'e.g. Daily journal',
            controller: _labelController,
          ),
          const SizedBox(height: 20),

          // Time
          Text('Time', style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickTime,
            child: BrutalistCard(
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 10),
                  Text(timeStr, style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Days of week
          Text('Days', style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final entry in {
                1: 'Mon',
                2: 'Tue',
                3: 'Wed',
                4: 'Thu',
                5: 'Fri',
                6: 'Sat',
                7: 'Sun',
              }.entries)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedDays.contains(entry.key)) {
                        if (_selectedDays.length > 1) {
                          _selectedDays.remove(entry.key);
                        }
                      } else {
                        _selectedDays.add(entry.key);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedDays.contains(entry.key)
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: _selectedDays.contains(entry.key)
                            ? DottrTheme.borderWidth
                            : 1.5,
                      ),
                      borderRadius:
                          BorderRadius.circular(DottrTheme.cardRadius),
                    ),
                    child: Text(
                      entry.value,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: _selectedDays.contains(entry.key)
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Template link
          Text('Template', style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          templatesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (templates) {
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  BrutalistChip(
                    label: 'None',
                    color: _templateId == null
                        ? theme.colorScheme.secondary
                        : null,
                    onTap: () => setState(() => _templateId = null),
                  ),
                  ...templates.map((t) => BrutalistChip(
                        label: t.name,
                        color: _templateId == t.id
                            ? theme.colorScheme.secondary
                            : null,
                        onTap: () => setState(() => _templateId = t.id),
                      )),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Save button
          Center(
            child: BrutalistButton(
              label: _isEditing ? 'Update' : 'Create',
              icon: Icons.check,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }

  Future<void> _save() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) return;

    final days = _selectedDays.toList()..sort();
    final notifier = ref.read(notificationProvider.notifier);

    if (_isEditing && widget.configId != null) {
      final configs = ref.read(notificationProvider).valueOrNull ?? [];
      final existing = configs.firstWhere((c) => c.id == widget.configId);
      await notifier.updateConfig(
        widget.configId!,
        existing.copyWith(
          label: label,
          hour: _hour,
          minute: _minute,
          daysOfWeek: days,
          templateId: _templateId,
        ),
      );
    } else {
      await notifier.addNew(
        label: label,
        hour: _hour,
        minute: _minute,
        daysOfWeek: days,
        templateId: _templateId,
      );
    }

    if (mounted) context.pop();
  }

  Future<void> _deleteConfig() async {
    if (widget.configId == null) return;
    await ref.read(notificationProvider.notifier).delete(widget.configId!);
    if (mounted) context.pop();
  }
}
