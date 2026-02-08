import 'dart:async';
import 'dart:developer' as developer;
import '../core/constants.dart';
import '../models/sync_status.dart';
import 'git_service.dart';

class SyncService {
  final GitService _gitService;
  Timer? _pollTimer;
  SyncStatus _status = SyncStatus.offline;
  final _statusController = StreamController<SyncStatus>.broadcast();

  SyncService(this._gitService);

  SyncStatus get status => _status;
  Stream<SyncStatus> get statusStream => _statusController.stream;

  void _setStatus(SyncStatus status) {
    _status = status;
    _statusController.add(status);
  }

  Future<void> startPolling() async {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Constants.syncPollInterval, (_) => sync());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> sync() async {
    if (!_gitService.isInitialized) return;

    try {
      _setStatus(SyncStatus.syncing);
      await _gitService.pull();

      if (await _gitService.hasChanges()) {
        await _gitService.addAll();
        await _gitService.commit('Auto-sync from Dottr');
        await _gitService.push();
      }

      _setStatus(SyncStatus.synced);
    } catch (e) {
      developer.log('Sync error: $e');
      _setStatus(SyncStatus.error);
    }
  }

  Future<void> commitAndPush(String message) async {
    if (!_gitService.isInitialized) return;

    try {
      _setStatus(SyncStatus.syncing);
      await _gitService.addAll();
      await _gitService.commit(message);
      await _gitService.push();
      _setStatus(SyncStatus.synced);
    } catch (e) {
      developer.log('Commit/push error: $e');
      _setStatus(SyncStatus.error);
    }
  }

  void dispose() {
    stopPolling();
    _statusController.close();
  }
}
