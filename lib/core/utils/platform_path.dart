import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants.dart';

Future<String> getJournalBasePath() async {
  if (kIsWeb) {
    // Web can't use the filesystem — return a dummy path.
    // File operations will be no-ops on web; this just prevents crashes
    // so the UI can be previewed.
    return '/tmp/dottr-web-preview';
  }
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, Constants.journalDirName);
}
