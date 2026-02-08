import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/dottl_theme.dart';
import 'providers/settings_provider.dart';
import 'router.dart';

class DottrApp extends ConsumerWidget {
  const DottrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Dottr',
      debugShowCheckedModeBanner: false,
      theme: DottrTheme.light(),
      darkTheme: DottrTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
