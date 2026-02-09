import '../models/entry.dart';

class OnThisDayService {
  /// Find entries from previous years that share the same month and day as [today].
  /// Optionally filter by [tagFilter] (entry must have at least one matching tag).
  static List<Entry> findEntries(
    List<Entry> allEntries,
    DateTime today, {
    List<String> tagFilter = const [],
  }) {
    return allEntries.where((entry) {
      // Same month+day, different year
      if (entry.date.month != today.month || entry.date.day != today.day) {
        return false;
      }
      if (entry.date.year == today.year) return false;

      // Tag filter: if non-empty, entry must contain at least one matching tag
      if (tagFilter.isNotEmpty) {
        return entry.tags.any((t) => tagFilter.contains(t));
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.year.compareTo(a.date.year)); // newest first
  }

  /// Human-readable label like "1 year ago" or "3 years ago".
  static String yearsAgoLabel(DateTime entryDate, DateTime today) {
    final diff = today.year - entryDate.year;
    return diff == 1 ? '1 year ago' : '$diff years ago';
  }
}
