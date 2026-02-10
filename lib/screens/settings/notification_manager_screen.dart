import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottr_theme.dart';
import '../../providers/notification_provider.dart';

class NotificationManagerScreen extends ConsumerWidget {
  const NotificationManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final configsAsync = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: configsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (configs) {
          if (configs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No reminders yet',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to create your first reminder',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: configs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final config = configs[index];
              final timeStr =
                  '${config.hour.toString().padLeft(2, '0')}:${config.minute.toString().padLeft(2, '0')}';
              final daysStr = _formatDays(config.daysOfWeek);

              return BrutalistCard(
                onTap: () => context.push(
                  '/settings/notifications/edit?id=${config.id}',
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.label,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$timeStr  $daysStr',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: config.enabled,
                      onChanged: (_) => ref
                          .read(notificationProvider.notifier)
                          .toggle(config.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: BrutalistFAB(
        icon: Icons.add,
        onPressed: () => context.push('/settings/notifications/edit'),
      ),
    );
  }

  String _formatDays(List<int> days) {
    if (days.length == 7) return 'Every day';
    if (days.length == 5 &&
        days.every((d) => d >= 1 && d <= 5)) {
      return 'Weekdays';
    }
    if (days.length == 2 &&
        days.contains(6) &&
        days.contains(7)) {
      return 'Weekends';
    }
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => names[d]).join(', ');
  }
}
