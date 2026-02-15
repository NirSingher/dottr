import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/platform_path.dart';
import '../models/sync_status.dart';
import '../services/git_config_service.dart';
import '../services/git_service.dart';
import '../services/git_service_github_api.dart';
import '../services/git_service_impl.dart';
import '../services/sync_service.dart';
import 'settings_provider.dart';

final gitConfigServiceProvider = Provider<GitConfigService>((ref) {
  return GitConfigService();
});

final gitServiceProvider = Provider<GitService>((ref) {
  // iOS/Android: use GitHub REST API (git_on_dart's remote ops are incomplete)
  // macOS/Linux/Windows: use Process.run('git', ...) for full git CLI
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    return GitServiceGithubApi();
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

  // Store PAT in sync service so subsequent sync() calls can authenticate
  syncService.setPat(pat);

  try {
    await gitService.initialize(journalPath);

    final isRepo = await gitService.isGitRepo();

    if (isRepo) {
      // Existing repo
      final hasOrigin = await gitService.hasRemote();
      if (hasOrigin) {
        // Update remote with current PAT and pull
        await gitService.setRemoteUrl(repoUrl, pat: pat);
        try {
          await gitService.pull(pat: pat);
        } on GitException catch (e) {
          // Pull may fail on empty remote or unrelated histories — not fatal
          developer.log('SyncInit: pull failed (non-fatal): $e');
        }
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
      // No .git but directory exists with files — init in place,
      // commit existing entries, then push to remote.
      await gitService.initRepo();
      await gitService.configUser('Dottr', 'dottr@local');
      await gitService.setRemoteUrl(repoUrl, pat: pat);

      // Commit any existing local files
      if (await gitService.hasChanges()) {
        await gitService.addAll();
        await gitService.commit('Initial import from Dottr');
      }

      // Try to pull remote content (may be empty repo — that's OK)
      try {
        await gitService.pull(pat: pat);
      } on GitException catch (e) {
        developer.log('SyncInit: pull after init failed (non-fatal): $e');
      }

      // Push local content to remote
      await gitService.push(pat: pat);
    }

    syncService.startPolling();
  } on GitException catch (e) {
    developer.log('SyncInit error: $e');
    syncService.lastError = '${e.message}${e.stderr != null ? ': ${e.stderr}' : ''}';
    if (e.isConflict) {
      syncService.setStatusExternal(SyncStatus.conflict);
    } else {
      syncService.setStatusExternal(SyncStatus.error);
    }
  } catch (e) {
    developer.log('SyncInit unexpected error: $e');
    syncService.lastError = e.toString();
    syncService.setStatusExternal(SyncStatus.error);
  }
});
