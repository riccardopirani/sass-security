/// Configure in App Store Connect / Play Console to match these IDs (or override via --dart-define).
const String kIapProductMonthly = String.fromEnvironment(
  'IAP_PRODUCT_MONTHLY',
  defaultValue: 'cyberguard_monthly',
);

const String kIapProductYearly = String.fromEnvironment(
  'IAP_PRODUCT_YEARLY',
  defaultValue: 'cyberguard_yearly',
);
