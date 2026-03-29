import 'dart:math';

/// `price = basePrice + (users * 0.22) + (users^1.1 * 0.02) + (riskScore * 0.05)`
double computeMonthlySubscriptionUsd({
  double basePrice = 2.99,
  required int users,
  required int riskScore,
}) {
  final u = min(50000, max(1, users)).toDouble();
  final rs = min(100, max(0, riskScore)).toDouble();
  return basePrice + u * 0.22 + pow(u, 1.1) * 0.02 + rs * 0.05;
}
