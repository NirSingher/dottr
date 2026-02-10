import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/platform_path.dart';
import '../models/sync_status.dart';
import '../services/git_config_service.dart';
import '../services/git_service.dart';
import '../services/git_service_impl.dart';
import '../services/git_service_libgit.dart';
import '../services/sync_service.dart';
import 'settings_provider.dart';

final gitConfigServiceProvider = Provider<GitConfigService>((ref) {
  return GitConfigService();
});

final gitServiceProvider = Provider<GitService>((ref) {
  // iOS/Android: use pure-Dart git_on_dart (no git binary needed)
  // macOS/Linux/Windows: use Process.run('git', ...) for full git CLI
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    return GitServiceLibgit();
  }
  return GitServiceImpl();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final gitService = ref.read(gitServiceProvider);
  final service = SyncService(gitService);
  ref.onDispose(() => service.dispose());
  return service;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return syncService.statusStream;
});

/// Initializes git sync on app start. Call once from the app's root.
final syncInitProvider = FutureProvider<void>((ref) async {
  if (kIsWeb) return;

  final gitService = ref.read(gitServiceProvider);
  final syncService = ref.read(syncServiceProvider);
  final configService = ref.read(gitConfigServiceProvider);
  final settings = ref.read(settingsProvider).valueOrNull;

  // On desktop, check if the git binary is available.
  // On iOS/Android, git_on_dart handles everything — skip this check.
  final usesCliGit = !(Platform.isIOS || Platform.isAndroid);
  if (usesCliGit) {
    final gitAvailable = await GitService.isGitAvailable();
    if (!gitAvailable) {
      developer.log('SyncInit: git not available, staying offline');
      return;
    }
  }

  // Load runtime config
  final repoUrl = settings?.gitRepoUrl ?? '';
  final pat = await configService.loadPat();
  if (repoUrl.isEmpty) {
    developer.log('SyncInit: no repo URL configured, staying offline');
    return;
  }

  final journalPath = await getJournalBasePath();

  try {
    await gitService.initialize(journalPath);

    final isRepo = await gitService.isGitRepo();

    if (isRepo) {
      // Existing repo
      final hasOrigin = await gitService.hasRemote();
      if (hasOrigin) {
        // Update remote with current PAT and pull
        await gitService.setRemoteUrl(repoUrl, pat: pat);
        await gitService.pull(pat: pat);
      } else {
        // Local repo with no remote — add origin and push
        await gitService.setRemoteUrl(repoUrl, pat: pat);
        await gitService.configUser('Dottr', 'dottr@local');
        if (await gitService.hasChanges()) {
          await gitService.addAll();
          await gitService.commit('Initial import');
        }
        await gitService.push(pat: pat);
      }
    } else {
      // No repo — clone from remote
      await gitService.clone(repoUrl, journalPath, pat: pat);
      await gitService.configUser('Dottr', 'dottr@local');
    }

    syncService.startPolling();
  } on GitException catch (e) {
    developer.log('SyncInit error: $e');
    if (e.isConflict) {
      syncService.setStatusExternal(SyncStatus.conflict);
    } else {
      syncService.setStatusExternal(SyncStatus.error);
    }
  } catch (e) {
    developer.log('SyncInit unexpected error: $e');
    syncService.setStatusExternal(SyncStatus.error);
  }
});
