import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import '../core/constants.dart';
import '../models/journal.dart';

class JournalService {
  late String _basePath;

  Future<void> initialize(String basePath) async {
    _basePath = basePath;
    final dir = Directory(p.join(_basePath, Constants.schemaDirName));
    await dir.create(recursive: true);
  }

  String get _journalFilePath =>
      p.join(_basePath, Constants.schemaDirName, Constants.journalFileName);

  Future<List<Journal>> loadJournals() async {
    final file = File(_journalFilePath);
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final parsed = loadYaml(content);
    if (parsed is! YamlMap) return [];

    final journals = parsed['journals'];
    if (journals is! YamlList) return [];

    return journals.map((item) {
      final map = <String, dynamic>{};
      if (item is YamlMap) {
        for (final entry in item.entries) {
          map[entry.key.toString()] = entry.value;
        }
      }
      return Journal.fromMap(map);
    }).toList();
  }

  Future<void> saveJournals(List<Journal> journals) async {
    final buffer = StringBuffer();
    buffer.writeln('journals:');
    for (final journal in journals) {
      buffer.writeln('  - id: ${journal.id}');
      buffer.writeln('    name: ${_yamlQuote(journal.name)}');
      buffer.writeln('    color: ${journal.color.toARGB32()}');
    }
    final file = File(_journalFilePath);
    await file.writeAsString(buffer.toString());
  }

  static final _yamlSpecialChars = RegExp(r'[:#\[\]{}&*!|>%@`]');

  String _yamlQuote(dynamic value) {
    if (value is bool || value is num) return value.toString();
    final str = value.toString();
    if (str.isEmpty ||
        _yamlSpecialChars.hasMatch(str) ||
        str.trimLeft() != str) {
      return '"${str.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
    }
    return str;
  }
}
