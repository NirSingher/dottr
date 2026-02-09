import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import '../core/constants.dart';
import '../models/template.dart';

class TemplateService {
  late String _basePath;

  Future<void> initialize(String basePath) async {
    _basePath = basePath;
    final dir = Directory(p.join(_basePath, Constants.schemaDirName));
    await dir.create(recursive: true);
  }

  String get _templateFilePath =>
      p.join(_basePath, Constants.schemaDirName, Constants.templateFileName);

  Future<List<EntryTemplate>> loadTemplates() async {
    final file = File(_templateFilePath);
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final parsed = loadYaml(content);
    if (parsed is! YamlMap) return [];

    final templates = parsed['templates'];
    if (templates is! YamlList) return [];

    return templates.map((item) {
      final map = <String, dynamic>{};
      if (item is YamlMap) {
        for (final entry in item.entries) {
          final value = entry.value;
          if (value is YamlList) {
            map[entry.key.toString()] = value.toList().cast<String>();
          } else if (value is YamlMap) {
            map[entry.key.toString()] = Map<String, dynamic>.from(value);
          } else {
            map[entry.key.toString()] = value;
          }
        }
      }
      return EntryTemplate.fromMap(map);
    }).toList();
  }

  Future<void> saveTemplates(List<EntryTemplate> templates) async {
    final buffer = StringBuffer();
    buffer.writeln('templates:');
    for (final template in templates) {
      buffer.writeln('  - id: ${template.id}');
      buffer.writeln('    name: ${_yamlQuote(template.name)}');
      buffer.writeln('    icon: ${template.icon.codePoint}');
      buffer.writeln('    color: ${template.color.toARGB32()}');
      if (template.tags.isNotEmpty) {
        buffer.writeln('    tags:');
        for (final tag in template.tags) {
          buffer.writeln('      - ${_yamlQuote(tag)}');
        }
      }
      if (template.mood != null) {
        buffer.writeln('    mood: ${_yamlQuote(template.mood!)}');
      }
      if (template.customProperties.isNotEmpty) {
        buffer.writeln('    custom_properties:');
        for (final entry in template.customProperties.entries) {
          buffer.writeln('      ${entry.key}: ${_yamlQuote(entry.value)}');
        }
      }
      if (template.body.isNotEmpty) {
        // Use YAML block scalar for multiline body
        buffer.writeln('    body: |');
        for (final line in template.body.split('\n')) {
          buffer.writeln('      $line');
        }
      }
    }
    final file = File(_templateFilePath);
    await file.writeAsString(buffer.toString());
  }

  static final _yamlSpecialChars = RegExp(r'[:#\[\]{}&*!|>%@`]');

  String _yamlQuote(dynamic value) {
    if (value is bool || value is num) return value.toString();
    final str = value.toString();
    if (str.isEmpty || _yamlSpecialChars.hasMatch(str) || str.trimLeft() != str) {
      return '"${str.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
    }
    return str;
  }
}
