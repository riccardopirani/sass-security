class BillingHistoryEvent {
  const BillingHistoryEvent({
    required this.id,
    required this.eventType,
    required this.details,
    required this.createdAt,
  });

  final String id;
  final String eventType;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  factory BillingHistoryEvent.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json['details'];
    return BillingHistoryEvent(
      id: json['id'] as String,
      eventType: json['event_type'] as String,
      details: detailsRaw is Map
          ? Map<String, dynamic>.from(detailsRaw)
          : <String, dynamic>{},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String? get effectiveAtIso => details['effective_at'] as String?;
}
