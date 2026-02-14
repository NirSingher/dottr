import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/brutalist_components.dart';
import '../../core/theme/dottr_theme.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Git sync
          _GitSyncCard(),
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

          // Journals
          BrutalistCard(
            onTap: () => context.push('/settings/journals'),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journals',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Organize entries into named journals',
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

          // On This Day
          _OnThisDaySettingsCard(),
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

          // Import
          BrutalistCard(
            onTap: () => context.push('/settings/import'),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Import entries from Day One',
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

class _GitSyncCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GitSyncCard> createState() => _GitSyncCardState();
}

class _GitSyncCardState extends ConsumerState<_GitSyncCard> {
  final _repoUrlController = TextEditingController();
  final _patController = TextEditingController();
  bool _connecting = false;

  @override
  void dispose() {
    _repoUrlController.dispose();
    _patController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final repoUrl = _repoUrlController.text.trim();
    final pat = _patController.text.trim();
    if (repoUrl.isEmpty || pat.isEmpty) return;

    setState(() => _connecting = true);

    // Save config
    await ref.read(settingsProvider.notifier).setGitRepoUrl(repoUrl);
    await ref.read(gitConfigServiceProvider).savePat(pat);

    // Re-trigger sync init
    ref.invalidate(syncInitProvider);

    if (mounted) setState(() => _connecting = false);
  }

  Future<void> _disconnect() async {
    await ref.read(settingsProvider.notifier).setGitRepoUrl('');
    await ref.read(gitConfigServiceProvider).deletePat();
    ref.read(syncServiceProvider).stopPolling();
    ref.read(syncServiceProvider).setStatusExternal(SyncStatus.offline);
    _repoUrlController.clear();
    _patController.clear();
  }

  Future<void> _syncNow() async {
    await ref.read(syncServiceProvider).sync();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final syncStatus = ref.watch(syncStatusProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final isConfigured = settings != null && settings.gitRepoUrl.isNotEmpty;

    return BrutalistCard(
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
          const SizedBox(height: 12),
          if (isConfigured) ...[
            Text(
              settings.gitRepoUrl,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.muted),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                BrutalistButton(
                  label: 'Sync Now',
                  compact: true,
                  icon: Icons.sync,
                  onPressed: _syncNow,
                ),
                const SizedBox(width: 8),
                BrutalistButton(
                  label: 'Disconnect',
                  compact: true,
                  color: theme.colorScheme.surface,
                  onPressed: _disconnect,
                ),
              ],
            ),
          ] else ...[
            Text(
              'Connect a GitHub repository to sync entries across devices.',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _repoUrlController,
              decoration: const InputDecoration(
                hintText: 'https://github.com/user/repo.git',
                isDense: true,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _patController,
              decoration: const InputDecoration(
                hintText: 'Personal access token',
                isDense: true,
              ),
              obscureText: true,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            BrutalistButton(
              label: _connecting ? 'Connecting...' : 'Connect',
              icon: Icons.link,
              compact: true,
              onPressed: _connecting ? null : _connect,
            ),
          ],
        ],
      ),
    );
  }
}

class _OnThisDaySettingsCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_OnThisDaySettingsCard> createState() =>
      _OnThisDaySettingsCardState();
}

class _OnThisDaySettingsCardState
    extends ConsumerState<_OnThisDaySettingsCard> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<DottrColors>()!;
    final settings = ref.watch(settingsProvider).valueOrNull;
    if (settings == null) return const SizedBox.shrink();

    return BrutalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('On This Day', style: theme.textTheme.titleLarge),
              ),
              Switch(
                value: settings.onThisDayEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setOnThisDayEnabled(v),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Show entries from previous years on the same date',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.muted),
          ),
          if (settings.onThisDayEnabled) ...[
            const SizedBox(height: 12),
            Text('Filter by tags', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            if (settings.onThisDayTags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: settings.onThisDayTags.map((tag) {
                  return BrutalistChip(
                    label: '#$tag',
                    onDelete: () {
                      final updated = settings.onThisDayTags
                          .where((t) => t != tag)
                          .toList();
                      ref
                          .read(settingsProvider.notifier)
                          .setOnThisDayTags(updated);
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Add tag filter...',
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
                  if (tag.isNotEmpty &&
                      !settings.onThisDayTags.contains(tag)) {
                    ref.read(settingsProvider.notifier).setOnThisDayTags(
                      [...settings.onThisDayTags, tag],
                    );
                  }
                  _tagController.clear();
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Daily notification',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Switch(
                  value: settings.onThisDayNotificationEnabled,
                  onChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .setOnThisDayNotificationEnabled(v),
                ),
              ],
            ),
            if (settings.onThisDayNotificationEnabled) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.onThisDayNotificationHour,
                      minute: settings.onThisDayNotificationMinute,
                    ),
                  );
                  if (picked != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .setOnThisDayNotificationTime(
                          picked.hour,
                          picked.minute,
                        );
                  }
                },
                child: BrutalistChip(
                  label:
                      '${settings.onThisDayNotificationHour.toString().padLeft(2, '0')}:${settings.onThisDayNotificationMinute.toString().padLeft(2, '0')}',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ThemeOption extends StatefulWidget {
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
  State<_ThemeOption> createState() => _ThemeOptionState();
}

class _ThemeOptionState extends State<_ThemeOption> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.selected
        ? theme.colorScheme.secondary
        : theme.colorScheme.surface;
    final bgColor = _hovered && !widget.selected
        ? Color.alphaBlend(
            theme.colorScheme.onSurface.withAlpha(20), baseColor)
        : baseColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: theme.colorScheme.outline,
              width: (widget.selected || _hovered)
                  ? DottrTheme.borderWidth
                  : 1.5,
            ),
            borderRadius: BorderRadius.circular(DottrTheme.cardRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
