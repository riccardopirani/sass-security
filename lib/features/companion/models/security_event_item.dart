class SecurityEventItem {
  const SecurityEventItem({
    required this.id,
    required this.eventKind,
    required this.severity,
    required this.status,
    required this.details,
    required this.createdAt,
  });

  final String id;
  final String eventKind;
  final String severity;
  final String status;
  final String details;
  final DateTime createdAt;

  factory SecurityEventItem.fromMap(Map<String, dynamic> map) {
    return SecurityEventItem(
      id: map['id'] as String,
      eventKind: (map['event_kind'] as String?) ?? 'unknown',
      severity: (map['severity'] as String?) ?? 'medium',
      status: (map['status'] as String?) ?? 'open',
      details: (map['details'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

