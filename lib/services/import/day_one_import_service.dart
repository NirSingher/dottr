import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import '../../models/entry.dart';

class DayOneImportResult {
  final int total;
  final int imported;
  final int skipped;
  final List<String> errors;

  const DayOneImportResult({
    this.total = 0,
    this.imported = 0,
    this.skipped = 0,
    this.errors = const [],
  });
}

class DayOneImportService {
  /// Parse a Day One JSON export ZIP and return Dottr entries.
  /// Text only — photos are ignored.
  Future<(List<Entry>, DayOneImportResult)> parseZip(String zipPath) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find Journal.json (may be at root or inside a folder)
    final jsonFile = archive.files.firstWhere(
      (f) => f.name.endsWith('Journal.json') || f.name.endsWith('.json'),
      orElse: () => throw Exception('No Journal.json found in ZIP'),
    );

    final jsonContent = utf8.decode(jsonFile.content as List<int>);
    final data = jsonDecode(jsonContent) as Map<String, dynamic>;
    final rawEntries = data['entries'] as List? ?? [];

    final entries = <Entry>[];
    final errors = <String>[];
    int skipped = 0;

    for (final raw in rawEntries) {
      try {
        final map = raw as Map<String, dynamic>;
        final entry = _mapEntry(map);
        if (entry != null) {
          entries.add(entry);
        } else {
          skipped++;
        }
      } catch (e) {
        errors.add(e.toString());
      }
    }

    final result = DayOneImportResult(
      total: rawEntries.length,
      imported: entries.length,
      skipped: skipped,
      errors: errors,
    );

    return (entries, result);
  }

  Entry? _mapEntry(Map<String, dynamic> map) {
    // creationDate is ISO 8601: "2024-03-15T14:30:00Z"
    final dateStr = map['creationDate'] as String?;
    if (dateStr == null) return null;
    final dateTime = DateTime.tryParse(dateStr);
    if (dateTime == null) return null;

    // Text field contains the body
    final text = map['text'] as String? ?? '';

    // Extract title: first markdown heading or first line
    String title;
    String body;
    final lines = text.split('\n');
    final headingMatch = RegExp(r'^#\s+(.+)$').firstMatch(lines.first);
    if (headingMatch != null) {
      title = headingMatch.group(1)!.trim();
      body = lines.skip(1).join('\n').trimLeft();
    } else if (lines.first.trim().isNotEmpty) {
      title = lines.first.trim();
      body = lines.skip(1).join('\n').trimLeft();
    } else {
      title = '';
      body = text;
    }

    // Tags
    final tags = (map['tags'] as List?)?.cast<String>() ?? [];

    // Location -> location string
    String? location;
    final locationMap = map['location'] as Map<String, dynamic>?;
    if (locationMap != null) {
      location = locationMap['placeName'] as String?;
    }

    // Weather -> custom properties
    final customProperties = <String, dynamic>{};
    final weather = map['weather'] as Map<String, dynamic>?;
    if (weather != null) {
      final desc = weather['conditionsDescription'] as String?;
      final tempC = weather['temperatureCelsius'];
      if (desc != null) customProperties['weather'] = desc;
      if (tempC != null) customProperties['temperature'] = '$tempC°C';
    }

    // Time string
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Entry(
      title: title,
      date: DateTime(dateTime.year, dateTime.month, dateTime.day),
      time: time,
      tags: tags,
      location: location,
      createdAt: dateTime,
      updatedAt: dateTime,
      customProperties: customProperties,
      body: body,
    );
  }
}
