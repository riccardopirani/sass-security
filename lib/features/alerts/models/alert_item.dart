class AlertItem {
  const AlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String severity;
  final bool isRead;
  final DateTime createdAt;

  factory AlertItem.fromMap(Map<String, dynamic> map) {
    return AlertItem(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
      severity: (map['severity'] as String?) ?? 'low',
      isRead: (map['is_read'] as bool?) ?? false,
      createdAt:
          DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
