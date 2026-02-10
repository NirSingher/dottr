import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/brutalist_components.dart';
import '../../../core/theme/dottr_theme.dart';
import '../../../models/entry.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback? onTap;

  const EntryCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final dateStr = DateFormat('MMM d').format(entry.date);
    final timeStr = entry.time ?? DateFormat('HH:mm').format(entry.date);

    return BrutalistCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: date/time + conflict badge
          Row(
            children: [
              Text(
                dateStr,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.muted,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.muted,
                ),
              ),
              if (entry.mood != null) ...[
                const SizedBox(width: 8),
                Text(entry.mood!, style: const TextStyle(fontSize: 14)),
              ],
              const Spacer(),
              if (entry.hasConflict)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.pink,
                    borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'CONFLICT',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            entry.title.isEmpty ? 'Untitled' : entry.title,
            style: theme.textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Body preview
          if (entry.body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              entry.body.replaceAll('\n', ' '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.muted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Tags
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: entry.tags
                  .map((tag) => BrutalistChip(label: '#$tag'))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
