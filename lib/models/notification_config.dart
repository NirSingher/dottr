class NotificationConfig {
  final String id;
  final String label;
  final int hour;
  final int minute;
  final List<int> daysOfWeek; // 1=Monday ... 7=Sunday (ISO)
  final bool enabled;
  final String? templateId;

  const NotificationConfig({
    required this.id,
    required this.label,
    this.hour = 9,
    this.minute = 0,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.enabled = true,
    this.templateId,
  });

  NotificationConfig copyWith({
    String? id,
    String? label,
    int? hour,
    int? minute,
    List<int>? daysOfWeek,
    bool? enabled,
    String? templateId,
  }) {
    return NotificationConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      enabled: enabled ?? this.enabled,
      templateId: templateId ?? this.templateId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'hour': hour,
        'minute': minute,
        'daysOfWeek': daysOfWeek,
        'enabled': enabled,
        if (templateId != null) 'templateId': templateId,
      };

  factory NotificationConfig.fromJson(Map<String, dynamic> json) {
    return NotificationConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      hour: json['hour'] as int? ?? 9,
      minute: json['minute'] as int? ?? 0,
      daysOfWeek: (json['daysOfWeek'] as List?)?.cast<int>() ??
          const [1, 2, 3, 4, 5, 6, 7],
      enabled: json['enabled'] as bool? ?? true,
      templateId: json['templateId'] as String?,
    );
  }
}
