import '../models/entry.dart';

abstract class FileService {
  Future<void> initialize(String basePath);
  Future<List<Entry>> listEntries();
  Future<Entry> readEntry(String filePath);
  Future<String> writeEntry(Entry entry);
  Future<void> deleteEntry(String filePath);
  Future<bool> exists(String filePath);
  Future<String> resolveFilePath(Entry entry);
}
