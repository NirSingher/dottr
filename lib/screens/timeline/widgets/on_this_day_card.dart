import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/brutalist_components.dart';
import '../../../core/theme/dottr_theme.dart';
import '../../../models/entry.dart';
import '../../../providers/on_this_day_provider.dart';
import '../../../services/on_this_day_service.dart';

class OnThisDayCard extends ConsumerWidget {
  const OnThisDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(onThisDayProvider);
    if (memories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: BrutalistCard(
        color: theme.colorScheme.secondary.withAlpha(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 20, color: colors.accentAlt),
                const SizedBox(width: 8),
                Text(
                  'On This Day',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: memories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final entry = memories[index];
                  return _MemoryChip(entry: entry, today: today);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryChip extends StatelessWidget {
  final Entry entry;
  final DateTime today;

  const _MemoryChip({required this.entry, required this.today});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final label = OnThisDayService.yearsAgoLabel(entry.date, today);

    return GestureDetector(
      onTap: () {
        if (entry.filePath != null) {
          context.push(
            '/viewer?path=${Uri.encodeComponent(entry.filePath!)}',
          );
        }
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.accentAlt,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                entry.title.isEmpty ? 'Untitled' : entry.title,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
