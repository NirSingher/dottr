import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottl_theme.dart';
import '../../models/sync_status.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sync_provider.dart';

const _accentColors = [
  Color(0xFFFFFFFF), // white (default)
  Color(0xFFFFE566), // yellow
  Color(0xFF5BC0EB), // blue
  Color(0xFFFE6D73), // pink
  Color(0xFF7AE582), // green
  Color(0xFFFFB347), // orange
  Color(0xFFCDB4DB), // lavender
  Color(0xFFE0E0E0), // silver
];

Color _contrastColor(Color c) =>
    c.computeLuminance() > 0.5 ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync status
          BrutalistCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sync', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SyncStatusDot(
                      color: syncStatus.when(
                        data: (status) => switch (status) {
                          SyncStatus.synced => colors.green,
                          SyncStatus.syncing => colors.accentAlt,
                          SyncStatus.conflict => colors.pink,
                          SyncStatus.offline => colors.muted,
                          SyncStatus.error => theme.colorScheme.error,
                        },
                        loading: () => colors.muted,
                        error: (e, st) => theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      syncStatus.when(
                        data: (status) => switch (status) {
                          SyncStatus.synced => 'Synced',
                          SyncStatus.syncing => 'Syncing...',
                          SyncStatus.conflict => 'Conflict detected',
                          SyncStatus.offline => 'Offline',
                          SyncStatus.error => 'Sync error',
                        },
                        loading: () => 'Checking...',
                        error: (e, st) => 'Error',
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (GitConfig.isConfigured) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Repository configured',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    'Git not configured. Set GIT_REPO_URL and GIT_PAT at build time.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Theme
          BrutalistCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ThemeOption(
                      label: 'System',
                      icon: Icons.brightness_auto,
                      selected: themeMode == ThemeMode.system,
                      onTap: () => ref
                          .read(settingsProvider.notifier)
                          .setThemeMode('system'),
                    ),
                    const SizedBox(width: 8),
                    _ThemeOption(
                      label: 'Light',
                      icon: Icons.light_mode,
                      selected: themeMode == ThemeMode.light,
                      onTap: () => ref
                          .read(settingsProvider.notifier)
                          .setThemeMode('light'),
                    ),
                    const SizedBox(width: 8),
                    _ThemeOption(
                      label: 'Dark',
                      icon: Icons.dark_mode,
                      selected: themeMode == ThemeMode.dark,
                      onTap: () => ref
                          .read(settingsProvider.notifier)
                          .setThemeMode('dark'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Accent color', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _accentColors.map((color) {
                    final selected =
                        color.toARGB32() == accentColor.toARGB32();
                    return GestureDetector(
                      onTap: () => ref
                          .read(settingsProvider.notifier)
                          .setAccentColor(color.toARGB32()),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: selected
                                ? DottrTheme.borderWidth
                                : 1.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            DottrTheme.cardRadius,
                          ),
                        ),
                        child: selected
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: _contrastColor(color),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Templates
          BrutalistCard(
            onTap: () => context.push('/settings/templates'),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Templates',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quick-start entries with pre-filled fields',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reminders
          BrutalistCard(
            onTap: () => context.push('/settings/notifications'),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminders',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recurring notifications to journal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Schema manager
          BrutalistCard(
            onTap: () => context.push('/settings/schemas'),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Properties',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Define custom fields for your entries',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About
          BrutalistCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Dottr v1.0.0',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'A portable markdown journal. Your entries are plain .md files with YAML frontmatter — no lock-in.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.secondary
              : theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline,
            width: selected ? DottrTheme.borderWidth : 1.5,
          ),
          borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
