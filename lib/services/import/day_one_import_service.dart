import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import '../../models/entry.dart';

class DayOneImportResult {
  final int total;
  final int imported;
  final int skipped;
  final List<String> errors;
  final Set<String> journalNames;

  const DayOneImportResult({
    this.total = 0,
    this.imported = 0,
    this.skipped = 0,
    this.errors = const [],
    this.journalNames = const {},
  });
}

class DayOneImportService {
  /// Parse a Day One JSON export ZIP and return Dottr entries.
  /// Text only — photos are ignored.
  /// Iterates all .json files in the zip — each may represent a different journal.
  Future<(List<Entry>, DayOneImportResult)> parseZip(String zipPath) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final jsonFiles =
        archive.files.where((f) => f.name.endsWith('.json')).toList();
    if (jsonFiles.isEmpty) {
      throw Exception('No JSON files found in ZIP');
    }

    final entries = <Entry>[];
    final errors = <String>[];
    final journalNames = <String>{};
    int totalRaw = 0;
    int skipped = 0;

    for (final jsonFile in jsonFiles) {
      try {
        final jsonContent = utf8.decode(jsonFile.content as List<int>);
        final data = jsonDecode(jsonContent) as Map<String, dynamic>;
        final rawEntries = data['entries'] as List? ?? [];
        totalRaw += rawEntries.length;

        // Extract journal name from metadata or filename
        String? journalName;
        final metadata = data['metadata'] as Map<String, dynamic>?;
        if (metadata != null) {
          journalName = metadata['journalName'] as String?;
        }
        journalName ??= _journalNameFromFilename(jsonFile.name);

        if (journalName != null) {
          journalNames.add(journalName);
        }

        for (final raw in rawEntries) {
          try {
            final map = raw as Map<String, dynamic>;
            final entry = _mapEntry(map, journalName: journalName);
            if (entry != null) {
              entries.add(entry);
            } else {
              skipped++;
            }
          } catch (e) {
            errors.add(e.toString());
          }
        }
      } catch (e) {
        errors.add('Error parsing ${jsonFile.name}: $e');
      }
    }

    final result = DayOneImportResult(
      total: totalRaw,
      imported: entries.length,
      skipped: skipped,
      errors: errors,
      journalNames: journalNames,
    );

    return (entries, result);
  }

  /// Extract journal name from a filename like "Journal - Work.json" or "Work.json".
  String? _journalNameFromFilename(String path) {
    final fileName = path.split('/').last.replaceAll('.json', '');
    if (fileName.isEmpty || fileName.toLowerCase() == 'journal') return null;
    // Handle "Journal - Name" format
    if (fileName.startsWith('Journal - ')) {
      return fileName.substring('Journal - '.length).trim();
    }
    return fileName;
  }

  Entry? _mapEntry(Map<String, dynamic> map, {String? journalName}) {
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
      journal: journalName,
      location: location,
      createdAt: dateTime,
      updatedAt: dateTime,
      customProperties: customProperties,
      body: body,
    );
  }
}
