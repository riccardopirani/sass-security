class SubscriptionRecord {
  const SubscriptionRecord({
    required this.plan,
    required this.status,
    this.currentPeriodEnd,
  });

  final String plan;
  final String status;
  final DateTime? currentPeriodEnd;

  factory SubscriptionRecord.fromMap(Map<String, dynamic> map) {
    return SubscriptionRecord(
      plan: (map['plan'] as String?) ?? 'starter',
      status: (map['status'] as String?) ?? 'inactive',
      currentPeriodEnd: map['current_period_end'] == null
          ? null
          : DateTime.tryParse(map['current_period_end'] as String),
    );
  }
}
