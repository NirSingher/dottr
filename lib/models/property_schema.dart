enum PropertyType {
  text,
  number,
  boolean,
  date,
  select,
  multiSelect,
}

class PropertySchema {
  final String name;
  final PropertyType type;
  final List<String>? options;
  final bool autoAdd;
  final bool required;
  final dynamic defaultValue;

  const PropertySchema({
    required this.name,
    required this.type,
    this.options,
    this.autoAdd = false,
    this.required = false,
    this.defaultValue,
  });

  PropertySchema copyWith({
    String? name,
    PropertyType? type,
    List<String>? options,
    bool? autoAdd,
    bool? required,
    dynamic defaultValue,
  }) {
    return PropertySchema(
      name: name ?? this.name,
      type: type ?? this.type,
      options: options ?? this.options,
      autoAdd: autoAdd ?? this.autoAdd,
      required: required ?? this.required,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      if (options != null) 'options': options,
      if (autoAdd) 'auto_add': autoAdd,
      if (required) 'required': required,
      if (defaultValue != null) 'default': defaultValue,
    };
  }

  factory PropertySchema.fromMap(Map<String, dynamic> map) {
    return PropertySchema(
      name: map['name'] as String,
      type: PropertyType.values.byName(map['type'] as String),
      options: (map['options'] as List?)?.cast<String>(),
      autoAdd: map['auto_add'] as bool? ?? false,
      required: map['required'] as bool? ?? false,
      defaultValue: map['default'],
    );
  }
}
