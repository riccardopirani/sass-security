/** Monthly subscription price in USD (before tax). */
export const BASE_PRICE_USD = 2.99;

/**
 * price = base_price + (users * 0.22) + (users^1.1 * 0.02) + (risk_score * 0.05)
 * risk_score clamped 0–100; users clamped 1–50000.
 */
export function computeMonthlyUsd(users: number, riskScore: number): number {
  const u = Math.min(50_000, Math.max(1, Math.floor(users)));
  const rs = Math.min(100, Math.max(0, Math.round(riskScore)));
  return BASE_PRICE_USD + u * 0.22 + Math.pow(u, 1.1) * 0.02 + rs * 0.05;
}

/** Stripe unit_amount (cents), minimum $0.50 USD. */
export function monthlyUsdToUnitCents(usd: number): number {
  return Math.max(50, Math.round(usd * 100));
}
