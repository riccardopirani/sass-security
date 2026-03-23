# CyberGuard Project Structure

```text
.
├── lib/
│   ├── app.dart
│   ├── main.dart
│   ├── core/
│   │   ├── config/env.dart
│   │   ├── localization/locale_controller.dart
│   │   ├── theme/app_theme.dart
│   │   ├── utils/app_snack.dart
│   │   └── widgets/
│   │       ├── empty_state.dart
│   │       ├── glass_card.dart
│   │       └── loading_skeleton.dart
│   ├── features/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── employees/
│   │   ├── alerts/
│   │   ├── phishing/
│   │   ├── subscription/
│   │   ├── settings/
│   │   └── shell/
│   └── l10n/
│       ├── app_en.arb
│       ├── app_it.arb
│       ├── app_de.arb
│       ├── app_fr.arb
│       ├── app_zh.arb
│       └── app_ru.arb
├── supabase/
│   ├── schema.sql
│   └── functions/
│       ├── _shared/
│       ├── send-phishing-test/
│       ├── stripe-checkout/
│       ├── create-checkout-session/
│       ├── create-billing-portal/
│       ├── report-security-alert/
│       └── stripe-webhook/
└── docs/
    ├── project_structure.md
    └── api_examples.md
```
