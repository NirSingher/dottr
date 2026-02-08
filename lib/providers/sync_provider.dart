import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_status.dart';
import '../services/git_service.dart';
import '../services/git_service_impl.dart';
import '../services/sync_service.dart';

final gitServiceProvider = Provider<GitService>((ref) {
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
