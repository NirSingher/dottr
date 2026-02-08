import 'package:flutter_test/flutter_test.dart';
import 'package:dottr/core/utils/frontmatter_parser.dart';

void main() {
  group('FrontmatterParser.parse', () {
    test('parses full frontmatter and body', () {
      const content = '''---
title: My Journal Entry
date: 2024-06-15
time: "14:30"
tags:
  - personal
  - reflection
mood: 😊
location: Coffee shop
created_at: 2024-06-15T14:30:00.000
updated_at: 2024-06-15T15:00:00.000
---
This is my journal body.

It has **multiple** paragraphs.
''';

      final entry = FrontmatterParser.parse(content);
      expect(entry.title, 'My Journal Entry');
      expect(entry.date.year, 2024);
      expect(entry.date.month, 6);
      expect(entry.date.day, 15);
      expect(entry.time, '14:30');
      expect(entry.tags, ['personal', 'reflection']);
      expect(entry.mood, '😊');
      expect(entry.location, 'Coffee shop');
      expect(entry.body, contains('multiple'));
      expect(entry.body, contains('paragraphs'));
    });

    test('parses empty frontmatter', () {
      const content = '''---
title: Empty
date: 2024-01-01
---
''';
      final entry = FrontmatterParser.parse(content);
      expect(entry.title, 'Empty');
      expect(entry.tags, isEmpty);
      expect(entry.body, isEmpty);
    });

    test('handles no frontmatter', () {
      const content = 'Just a plain markdown file.';
      final entry = FrontmatterParser.parse(content);
      expect(entry.body, content);
    });

    test('preserves custom properties', () {
      const content = '''---
title: Custom
date: 2024-01-01
weather: sunny
energy: 8
---
Body text.
''';
      final entry = FrontmatterParser.parse(content);
      expect(entry.customProperties['weather'], 'sunny');
      expect(entry.customProperties['energy'], 8);
    });

    test('handles special characters in YAML values', () {
      const content = '''---
title: "Entry with: colons and #hashes"
date: 2024-01-01
location: "San Francisco, CA"
---
Body.
''';
      final entry = FrontmatterParser.parse(content);
      expect(entry.title, 'Entry with: colons and #hashes');
      expect(entry.location, 'San Francisco, CA');
    });

    test('derives title from filePath when title missing', () {
      const content = '''---
date: 2024-01-01
---
Body.
''';
      final entry = FrontmatterParser.parse(
        content,
        filePath: '2024/01/2024-01-01_my-great-day.md',
      );
      expect(entry.title, 'my great day');
    });
  });

  group('FrontmatterParser round-trip', () {
    test('serialize then parse preserves data', () {
      const content = '''---
title: Round Trip Test
date: 2024-03-20
time: "09:15"
tags:
  - test
  - roundtrip
mood: 🔥
location: Home
created_at: 2024-03-20T09:15:00.000
updated_at: 2024-03-20T09:20:00.000
---
This is the body.

With multiple lines.
''';

      final original = FrontmatterParser.parse(content);
      final serialized = FrontmatterParser.serialize(original);
      final reparsed = FrontmatterParser.parse(serialized);

      expect(reparsed.title, original.title);
      expect(reparsed.date.year, original.date.year);
      expect(reparsed.date.month, original.date.month);
      expect(reparsed.date.day, original.date.day);
      expect(reparsed.time, original.time);
      expect(reparsed.tags, original.tags);
      expect(reparsed.mood, original.mood);
      expect(reparsed.location, original.location);
      expect(reparsed.body.trim(), original.body.trim());
    });

    test('round-trip with custom properties', () {
      const content = '''---
title: Custom Props
date: 2024-01-01
created_at: 2024-01-01T00:00:00.000
updated_at: 2024-01-01T00:00:00.000
weather: cloudy
rating: 7
---
Some content.
''';

      final original = FrontmatterParser.parse(content);
      final serialized = FrontmatterParser.serialize(original);
      final reparsed = FrontmatterParser.parse(serialized);

      expect(reparsed.customProperties['weather'], 'cloudy');
      expect(reparsed.customProperties['rating'], 7);
    });
  });
}
