import 'package:flutter_test/flutter_test.dart';
import 'package:dottr/core/utils/slug.dart';
import 'package:dottr/models/entry.dart';

void main() {
  group('toSlug', () {
    test('converts simple title', () {
      expect(toSlug('My Great Day'), 'my-great-day');
    });

    test('removes special characters', () {
      expect(toSlug('Hello, World! @2024'), 'hello-world-2024');
    });

    test('collapses multiple spaces and hyphens', () {
      expect(toSlug('Too   Many   Spaces'), 'too-many-spaces');
      expect(toSlug('Too---Many---Hyphens'), 'too-many-hyphens');
    });

    test('strips leading and trailing hyphens', () {
      expect(toSlug(' Leading Space '), 'leading-space');
      expect(toSlug('-leading-hyphen-'), 'leading-hyphen');
    });

    test('handles empty string', () {
      expect(toSlug(''), '');
    });

    test('handles only special characters', () {
      expect(toSlug('!@#\$%^&*()'), '');
    });
  });

  group('Entry.fileName', () {
    test('generates correct filename', () {
      final entry = Entry(
        title: 'My Great Day',
        date: DateTime(2024, 6, 15),
        createdAt: DateTime(2024, 6, 15),
        updatedAt: DateTime(2024, 6, 15),
      );
      expect(entry.fileName, '2024-06-15_my-great-day.md');
    });

    test('generates correct directory path', () {
      final entry = Entry(
        title: 'Test',
        date: DateTime(2024, 1, 5),
        createdAt: DateTime(2024, 1, 5),
        updatedAt: DateTime(2024, 1, 5),
      );
      expect(entry.directoryPath, '2024/01');
    });

    test('handles empty title', () {
      final entry = Entry(
        title: '',
        date: DateTime(2024, 12, 25),
        createdAt: DateTime(2024, 12, 25),
        updatedAt: DateTime(2024, 12, 25),
      );
      expect(entry.fileName, '2024-12-25_untitled.md');
    });
  });
}
