class Entry {
  final String? filePath;
  final String title;
  final DateTime date;
  final String? time;
  final List<String> tags;
  final String? mood;
  final String? journal;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> customProperties;
  final String body;
  final bool hasConflict;

  const Entry({
    this.filePath,
    required this.title,
    required this.date,
    this.time,
    this.tags = const [],
    this.mood,
    this.journal,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.customProperties = const {},
    this.body = '',
    this.hasConflict = false,
  });

  Entry copyWith({
    String? filePath,
    String? title,
    DateTime? date,
    String? time,
    List<String>? tags,
    String? mood,
    String? journal,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customProperties,
    String? body,
    bool? hasConflict,
  }) {
    return Entry(
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      journal: journal ?? this.journal,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customProperties: customProperties ?? this.customProperties,
      body: body ?? this.body,
      hasConflict: hasConflict ?? this.hasConflict,
    );
  }

  String get slug {
    final s = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return s.isEmpty ? 'untitled' : s;
  }

  String get fileName {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${dateStr}_$slug.md';
  }

  String get directoryPath {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$year/$month';
  }
}
