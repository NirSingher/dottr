import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config.dart';

class GitConfigService {
  static const _patKey = 'git_pat';
  final FlutterSecureStorage _secureStorage;

  GitConfigService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Load PAT from secure storage, falling back to build-time value.
  Future<String> loadPat() async {
    final stored = await _secureStorage.read(key: _patKey);
    if (stored != null && stored.isNotEmpty) return stored;
    return GitConfig.pat;
  }

  /// Save PAT to secure storage.
  Future<void> savePat(String pat) async {
    await _secureStorage.write(key: _patKey, value: pat);
  }

  /// Delete PAT from secure storage.
  Future<void> deletePat() async {
    await _secureStorage.delete(key: _patKey);
  }
}
