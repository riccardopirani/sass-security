class SubscriptionRecord {
  const SubscriptionRecord({
    required this.plan,
    required this.status,
    this.currentPeriodEnd,
    this.licensedSeats,
    this.stripeSubscriptionId,
    this.billingInterval = 'month',
    this.billingProvider = 'stripe',
  });

  final String plan;
  final String status;
  final DateTime? currentPeriodEnd;
  final int? licensedSeats;
  final String? stripeSubscriptionId;
  /// Stripe price recurring interval: `month` or `year`.
  final String billingInterval;
  /// `stripe` | `app_store` | `play_store`
  final String billingProvider;

  factory SubscriptionRecord.fromMap(Map<String, dynamic> map) {
    final seatsRaw = map['licensed_seats'];
    final intervalRaw = (map['billing_interval'] as String?)?.toLowerCase();
    final providerRaw = (map['billing_provider'] as String?)?.toLowerCase();
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
      billingInterval: intervalRaw == 'year' ? 'year' : 'month',
      billingProvider: providerRaw == 'app_store' || providerRaw == 'play_store'
          ? providerRaw!
          : 'stripe',
    );
  }

  bool get isNativeStoreBilling =>
      billingProvider == 'app_store' || billingProvider == 'play_store';

  bool get canRequestStripeCancel {
    if (isNativeStoreBilling) {
      return false;
    }
    if (stripeSubscriptionId == null || stripeSubscriptionId!.isEmpty) {
      return false;
    }
    final s = status.toLowerCase();
    return s == 'active' || s == 'trialing' || s == 'past_due';
  }

  /// Switch from annual to monthly starting at the next renewal (Stripe schedule).
  bool get canScheduleMonthlyAtRenewal {
    if (isNativeStoreBilling) {
      return false;
    }
    if (stripeSubscriptionId == null || stripeSubscriptionId!.isEmpty) {
      return false;
    }
    if (billingInterval != 'year') {
      return false;
    }
    final s = status.toLowerCase();
    return s == 'active' || s == 'trialing';
  }
}
