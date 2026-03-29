# CyberGuard Example API Calls

Replace the values in angle brackets before running.

## 1. Stripe Checkout Session

```bash
curl -X POST "<SUPABASE_URL>/functions/v1/stripe-checkout" \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "apikey: <SUPABASE_ANON_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"users":10}'
```

## 2. Billing Portal Session

```bash
curl -X POST "<SUPABASE_URL>/functions/v1/create-billing-portal" \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "apikey: <SUPABASE_ANON_KEY>" \
  -H "Content-Type: application/json"
```

## 3. Send Phishing Simulation

```bash
curl -X POST "<SUPABASE_URL>/functions/v1/send-phishing-test" \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "apikey: <SUPABASE_ANON_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Q2 Invoice Reminder",
    "template":"Please review attached invoice by EOD.",
    "simulateBehavior": true
  }'
```

## 4. Stripe Webhook (Local Test via Stripe CLI)

```bash
stripe listen --forward-to http://127.0.0.1:54321/functions/v1/stripe-webhook
```

```bash
stripe trigger checkout.session.completed
stripe trigger invoice.paid
stripe trigger invoice.payment_failed
stripe trigger customer.subscription.updated
```

## 5. Report Security Alert (Virus/Hacking)

```bash
curl -X POST "<SUPABASE_URL>/functions/v1/report-security-alert" \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "apikey: <SUPABASE_ANON_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "incidentType":"virus",
    "severity":"high",
    "title":"Ransomware behavior detected",
    "details":"Un endpoint started encrypting shared files."
  }'
```

## 6. Fetch Security News (Virus/Hacking/Tools)

```bash
curl -X POST "<SUPABASE_URL>/functions/v1/security-news" \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "apikey: <SUPABASE_ANON_KEY>" \
  -H "Content-Type: application/json"
```
