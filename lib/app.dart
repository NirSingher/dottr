import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/dottr_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/sync_provider.dart';
import 'router.dart';

class DottrApp extends ConsumerWidget {
  const DottrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accent = ref.watch(accentColorProvider);

    // Trigger git sync initialization
    ref.watch(syncInitProvider);

    return MaterialApp.router(
      title: 'Dottr',
      debugShowCheckedModeBanner: false,
      theme: DottrTheme.light(accent: accent),
      darkTheme: DottrTheme.dark(accent: accent),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
