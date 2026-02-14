import 'package:flutter/material.dart';

class Journal {
  final String id;
  final String name;
  final Color color;

  const Journal({
    required this.id,
    required this.name,
    this.color = const Color(0xFFFFDE59),
  });

  Journal copyWith({
    String? id,
    String? name,
    Color? color,
  }) {
    return Journal(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGB32(),
    };
  }

  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map['id'] as String,
      name: map['name'] as String,
      color: Color(map['color'] as int? ?? 0xFFFFDE59),
    );
  }
}
