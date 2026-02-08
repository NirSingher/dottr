import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import '../core/constants.dart';
import '../models/property_schema.dart';

class SchemaService {
  late String _basePath;

  Future<void> initialize(String basePath) async {
    _basePath = basePath;
    final dir = Directory(p.join(_basePath, Constants.schemaDirName));
    await dir.create(recursive: true);
  }

  String get _schemaFilePath =>
      p.join(_basePath, Constants.schemaDirName, Constants.schemaFileName);

  Future<List<PropertySchema>> loadSchemas() async {
    final file = File(_schemaFilePath);
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final parsed = loadYaml(content);
    if (parsed is! YamlMap) return [];

    final properties = parsed['properties'];
    if (properties is! YamlList) return [];

    return properties.map((item) {
      final map = <String, dynamic>{};
      if (item is YamlMap) {
        for (final entry in item.entries) {
          final value = entry.value;
          if (value is YamlList) {
            map[entry.key.toString()] = value.toList().cast<String>();
          } else {
            map[entry.key.toString()] = value;
          }
        }
      }
      return PropertySchema.fromMap(map);
    }).toList();
  }

  Future<void> saveSchemas(List<PropertySchema> schemas) async {
    final buffer = StringBuffer();
    buffer.writeln('properties:');
    for (final schema in schemas) {
      buffer.writeln('  - name: ${schema.name}');
      buffer.writeln('    type: ${schema.type.name}');
      if (schema.options != null && schema.options!.isNotEmpty) {
        buffer.writeln('    options:');
        for (final option in schema.options!) {
          buffer.writeln('      - $option');
        }
      }
      if (schema.autoAdd) buffer.writeln('    auto_add: true');
      if (schema.required) buffer.writeln('    required: true');
      if (schema.defaultValue != null) {
        buffer.writeln('    default: ${schema.defaultValue}');
      }
    }
    final file = File(_schemaFilePath);
    await file.writeAsString(buffer.toString());
  }
}
