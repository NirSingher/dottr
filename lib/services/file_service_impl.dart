import 'dart:io';
import 'package:path/path.dart' as p;
import '../core/utils/frontmatter_parser.dart';
import '../models/entry.dart';
import 'file_service.dart';

class FileServiceImpl implements FileService {
  late String _basePath;

  @override
  Future<void> initialize(String basePath) async {
    _basePath = basePath;
    await Directory(_basePath).create(recursive: true);
  }

  @override
  Future<List<Entry>> listEntries() async {
    final entries = <Entry>[];
    final dir = Directory(_basePath);
    if (!await dir.exists()) return entries;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.md')) {
        final relativePath = p.relative(entity.path, from: _basePath);
        // Skip conflict files for main listing — they'll be flagged on the original
        if (relativePath.contains('.conflict-')) continue;
        try {
          final content = await entity.readAsString();
          final entry = FrontmatterParser.parse(content, filePath: relativePath);

          // Check if a conflict file exists for this entry
          final conflictPattern = entity.path.replaceAll('.md', '.conflict-');
          final parentDir = entity.parent;
          bool hasConflict = false;
          await for (final sibling in parentDir.list()) {
            if (sibling.path.startsWith(conflictPattern)) {
              hasConflict = true;
              break;
            }
          }

          entries.add(entry.copyWith(hasConflict: hasConflict));
        } catch (_) {
          // Skip files that can't be parsed
        }
      }
    }

    // Sort by date descending
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  @override
  Future<Entry> readEntry(String filePath) async {
    final file = File(p.join(_basePath, filePath));
    final content = await file.readAsString();
    return FrontmatterParser.parse(content, filePath: filePath);
  }

  @override
  Future<String> writeEntry(Entry entry) async {
    final filePath = await resolveFilePath(entry);
    final fullPath = p.join(_basePath, filePath);
    final file = File(fullPath);
    await file.parent.create(recursive: true);
    final content = FrontmatterParser.serialize(entry);
    await file.writeAsString(content);
    return filePath;
  }

  @override
  Future<void> deleteEntry(String filePath) async {
    final file = File(p.join(_basePath, filePath));
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> exists(String filePath) async {
    return File(p.join(_basePath, filePath)).exists();
  }

  @override
  Future<String> resolveFilePath(Entry entry) async {
    if (entry.filePath != null) return entry.filePath!;

    final dirPath = entry.directoryPath;
    final fileName = entry.fileName;
    var candidate = p.join(dirPath, fileName);

    // Handle collision
    var counter = 1;
    while (await exists(candidate)) {
      final base = fileName.replaceAll('.md', '');
      candidate = p.join(dirPath, '$base-$counter.md');
      counter++;
    }

    return candidate;
  }
}
