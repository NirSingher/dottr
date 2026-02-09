import 'package:flutter/material.dart';

class EntryTemplate {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final String? mood;
  final Map<String, dynamic> customProperties;
  final String body;

  const EntryTemplate({
    required this.id,
    required this.name,
    this.icon = Icons.description_outlined,
    this.color = const Color(0xFFFFDE59),
    this.tags = const [],
    this.mood,
    this.customProperties = const {},
    this.body = '',
  });

  EntryTemplate copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    List<String>? tags,
    String? mood,
    Map<String, dynamic>? customProperties,
    String? body,
  }) {
    return EntryTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      customProperties: customProperties ?? this.customProperties,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.toARGB32(),
      if (tags.isNotEmpty) 'tags': tags,
      if (mood != null) 'mood': mood,
      if (customProperties.isNotEmpty) 'custom_properties': customProperties,
      if (body.isNotEmpty) 'body': body,
    };
  }

  factory EntryTemplate.fromMap(Map<String, dynamic> map) {
    return EntryTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: IconData(
        map['icon'] as int? ?? Icons.description_outlined.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(map['color'] as int? ?? 0xFFFFDE59),
      tags: (map['tags'] as List?)?.cast<String>() ?? const [],
      mood: map['mood'] as String?,
      customProperties:
          (map['custom_properties'] as Map?)?.cast<String, dynamic>() ??
              const {},
      body: map['body'] as String? ?? '',
    );
  }
}
