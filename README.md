# CyberGuard

Production-ready SaaS starter for SMB cybersecurity with Flutter (web/mobile), Supabase, and Stripe subscriptions.

## Tech Stack

- Frontend: Flutter (responsive Web + Mobile)
- Backend: Supabase (PostgreSQL, Auth, Realtime, Edge Functions)
- Payments: Stripe Checkout, subscriptions, billing portal, webhooks

## Delivered Core Features

- Supabase Auth (email/password)
- Roles: `admin`, `employee`
- Company multi-tenancy with strict RLS
- Dashboard with:
  - company risk score (0-100)
  - active phishing campaigns
  - open alerts
  - employee risk ranking
- Employee CRUD (`name`, `email`, `role`, `risk_score`, `training_completion`)
- Phishing simulation trigger + opened/clicked tracking
- Real-time alerts with severity (`low`, `medium`, `high`)
- Incident reporting from `Alerts` (`virus`/`hacking`) with company-wide email notification
- News section with free cyber feeds (Hacker News, Reddit, StackExchange, BleepingComputer)
- Security score engine (phishing behavior + training completion)
- Stripe plans: `starter`, `pro`, `business`
- Language support:
  - English (`en`)
  - Italian (`it`)
  - German (`de`)
  - French (`fr`)
  - Chinese Simplified (`zh`)
  - Russian (`ru`)

## Flutter Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Run app:

```bash
flutter run \
  --dart-define=SUPABASE_URL=<your_supabase_url> \
  --dart-define=SUPABASE_ANON_KEY=<your_supabase_anon_key> \
  --dart-define=STRIPE_PUBLISHABLE_KEY=<your_stripe_publishable_key>
```

## Supabase Setup

1. Apply schema:

```sql
-- Run supabase/schema.sql
```

2. Set Edge Function secrets:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_PRICE_STARTER`
- `STRIPE_PRICE_PRO`
- `STRIPE_PRICE_BUSINESS`
- `APP_URL`
- `RESEND_API_KEY`
- `ALERTS_FROM_EMAIL`

3. Deploy functions:

```bash
supabase functions deploy stripe-checkout
supabase functions deploy create-checkout-session
supabase functions deploy create-billing-portal
supabase functions deploy stripe-webhook
supabase functions deploy send-phishing-test
supabase functions deploy report-security-alert
supabase functions deploy security-news
```

## Stripe Webhooks Handled

- `checkout.session.completed`
- `invoice.paid`
- `invoice.payment_failed`
- `customer.subscription.updated`
- `customer.subscription.deleted`

## Files You Asked For

- Flutter project modules under `lib/`
- SQL schema + RLS in `supabase/schema.sql`
- Edge Functions in `supabase/functions/*`
- Stripe integration in:
  - `supabase/functions/stripe-checkout/index.ts`
  - `supabase/functions/create-billing-portal/index.ts`
  - `supabase/functions/stripe-webhook/index.ts`
  - `lib/features/subscription/data/subscription_service.dart`
- Localizations in `lib/l10n/*.arb`
- Example API calls in `docs/api_examples.md`
- Project structure in `docs/project_structure.md`
