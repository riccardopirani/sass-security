class SubscriptionRecord {
  const SubscriptionRecord({
    required this.plan,
    required this.status,
    this.currentPeriodEnd,
    this.licensedSeats,
    this.stripeSubscriptionId,
  });

  final String plan;
  final String status;
  final DateTime? currentPeriodEnd;
  final int? licensedSeats;
  final String? stripeSubscriptionId;

  factory SubscriptionRecord.fromMap(Map<String, dynamic> map) {
    final seatsRaw = map['licensed_seats'];
    return SubscriptionRecord(
      plan: (map['plan'] as String?) ?? 'flex',
      status: (map['status'] as String?) ?? 'inactive',
      currentPeriodEnd: map['current_period_end'] == null
          ? null
          : DateTime.tryParse(map['current_period_end'] as String),
      licensedSeats: seatsRaw == null
          ? null
          : (seatsRaw is num ? seatsRaw.toInt() : int.tryParse('$seatsRaw')),
      stripeSubscriptionId: map['stripe_subscription_id'] as String?,
    );
  }

  bool get canRequestStripeCancel {
    if (stripeSubscriptionId == null || stripeSubscriptionId!.isEmpty) {
      return false;
    }
    final s = status.toLowerCase();
    return s == 'active' || s == 'trialing' || s == 'past_due';
  }
}
