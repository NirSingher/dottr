import 'package:yaml/yaml.dart';
import '../../models/entry.dart';

class FrontmatterParser {
  static const _delimiter = '---';

  static final _knownKeys = {
    'title',
    'date',
    'time',
    'tags',
    'mood',
    'location',
    'created_at',
    'updated_at',
  };

  /// Parse a markdown string with YAML frontmatter into an Entry.
  static Entry parse(String content, {String? filePath}) {
    final frontmatter = <String, dynamic>{};
    String body = content;

    if (content.startsWith('$_delimiter\n') ||
        content.startsWith('$_delimiter\r\n')) {
      final endIndex = content.indexOf(
        '\n$_delimiter',
        _delimiter.length + 1,
      );
      if (endIndex != -1) {
        final yamlStr = content.substring(_delimiter.length + 1, endIndex);
        final parsed = loadYaml(yamlStr);
        if (parsed is YamlMap) {
          for (final entry in parsed.entries) {
            frontmatter[entry.key.toString()] = _convertYamlValue(entry.value);
          }
        }
        // Body starts after the closing delimiter and its newline
        final bodyStart = endIndex + _delimiter.length + 1;
        if (bodyStart < content.length) {
          body = content.substring(bodyStart);
          // Strip leading newline after closing delimiter
          if (body.startsWith('\n')) {
            body = body.substring(1);
          } else if (body.startsWith('\r\n')) {
            body = body.substring(2);
          }
        } else {
          body = '';
        }
      }
    }

    final now = DateTime.now();
    final dateValue = _parseDate(frontmatter['date']) ?? now;

    // Separate custom properties from known keys
    final customProperties = <String, dynamic>{};
    for (final entry in frontmatter.entries) {
      if (!_knownKeys.contains(entry.key)) {
        customProperties[entry.key] = entry.value;
      }
    }

    return Entry(
      filePath: filePath,
      title: frontmatter['title']?.toString() ?? _titleFromFilePath(filePath),
      date: dateValue,
      time: frontmatter['time']?.toString(),
      tags: _parseTags(frontmatter['tags']),
      mood: frontmatter['mood']?.toString(),
      location: frontmatter['location']?.toString(),
      createdAt: _parseDateTime(frontmatter['created_at']) ?? now,
      updatedAt: _parseDateTime(frontmatter['updated_at']) ?? now,
      customProperties: customProperties,
      body: body,
    );
  }

  /// Serialize an Entry back to a markdown string with YAML frontmatter.
  static String serialize(Entry entry) {
    final buffer = StringBuffer();
    buffer.writeln(_delimiter);
    buffer.writeln('title: ${_yamlString(entry.title)}');
    buffer.writeln('date: ${_formatDate(entry.date)}');
    if (entry.time != null) {
      buffer.writeln('time: "${entry.time}"');
    }
    if (entry.tags.isNotEmpty) {
      buffer.writeln('tags:');
      for (final tag in entry.tags) {
        buffer.writeln('  - $tag');
      }
    }
    if (entry.mood != null) {
      buffer.writeln('mood: ${_yamlString(entry.mood!)}');
    }
    if (entry.location != null) {
      buffer.writeln('location: ${_yamlString(entry.location!)}');
    }
    buffer.writeln('created_at: ${entry.createdAt.toIso8601String()}');
    buffer.writeln('updated_at: ${entry.updatedAt.toIso8601String()}');

    // Write custom properties
    for (final kvp in entry.customProperties.entries) {
      buffer.writeln('${kvp.key}: ${_serializeValue(kvp.value)}');
    }

    buffer.writeln(_delimiter);
    if (entry.body.isNotEmpty) {
      buffer.write(entry.body);
      if (!entry.body.endsWith('\n')) {
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  static dynamic _convertYamlValue(dynamic value) {
    if (value is YamlList) {
      return value.map(_convertYamlValue).toList();
    }
    if (value is YamlMap) {
      return Map.fromEntries(
        value.entries.map(
          (e) => MapEntry(e.key.toString(), _convertYamlValue(e.value)),
        ),
      );
    }
    return value;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final str = value.toString();
    return DateTime.tryParse(str);
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final str = value.toString();
    return DateTime.tryParse(str);
  }

  static List<String> _parseTags(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _yamlString(String value) {
    if (value.contains(':') ||
        value.contains('#') ||
        value.contains('"') ||
        value.contains("'") ||
        value.contains('\n') ||
        value.startsWith(' ') ||
        value.endsWith(' ')) {
      final escaped = value.replaceAll('"', r'\"');
      return '"$escaped"';
    }
    return value;
  }

  static String _serializeValue(dynamic value) {
    if (value is String) return _yamlString(value);
    if (value is List) return value.toString();
    return value.toString();
  }

  static String _titleFromFilePath(String? filePath) {
    if (filePath == null) return 'Untitled';
    final fileName = filePath.split('/').last;
    // Remove date prefix and extension: 2024-01-15_my-title.md -> my-title
    final withoutExt = fileName.replaceAll('.md', '');
    final parts = withoutExt.split('_');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ').replaceAll('-', ' ');
    }
    return withoutExt.replaceAll('-', ' ');
  }
}
