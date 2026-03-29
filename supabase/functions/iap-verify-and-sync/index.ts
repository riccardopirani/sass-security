import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { GoogleAuth } from 'npm:google-auth-library@9.14.2';

import { handleOptions, json } from '../_shared/cors.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

const seatMapFromEnv = (): Record<string, number> => {
  const raw = Deno.env.get('IAP_PRODUCT_SEATS_JSON');
  if (raw) {
    try {
      const o = JSON.parse(raw) as Record<string, number>;
      return o;
    } catch {
      /* fall through */
    }
  }
  return {
    cyberguard_monthly: 10,
    cyberguard_yearly: 10,
  };
};

const seatsForProduct = (productId: string): number => {
  const map = seatMapFromEnv();
  const n = map[productId];
  return typeof n === 'number' && n >= 1 ? Math.min(50_000, n) : 10;
};

type AppleVerifyResponse = {
  status: number;
  latest_receipt_info?: Array<{
    product_id?: string;
    expires_date_ms?: string;
    original_transaction_id?: string;
  }>;
};

const verifyAppleReceipt = async (
  receiptBase64: string,
): Promise<{ ok: boolean; productId?: string; originalTx?: string; expires?: Date }> => {
  const password = Deno.env.get('APPSTORE_SHARED_SECRET');
  if (!password) {
    return { ok: false };
  }
  const body = {
    'receipt-data': receiptBase64,
    password,
    'exclude-old-transactions': true,
  };
  const prodUrl = 'https://buy.itunes.apple.com/verifyReceipt';
  const sandboxUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';

  let res = await fetch(prodUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  let data = (await res.json()) as AppleVerifyResponse;

  if (data.status === 21007) {
    res = await fetch(sandboxUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    data = (await res.json()) as AppleVerifyResponse;
  }

  if (data.status !== 0 || !data.latest_receipt_info?.length) {
    return { ok: false };
  }

  const sorted = [...data.latest_receipt_info].sort((a, b) =>
    Number(b.expires_date_ms ?? 0) - Number(a.expires_date_ms ?? 0)
  );
  const top = sorted[0];
  const expires = top.expires_date_ms ? new Date(Number(top.expires_date_ms)) : undefined;
  if (expires && expires.getTime() < Date.now()) {
    return { ok: false };
  }

  return {
    ok: true,
    productId: top.product_id,
    originalTx: top.original_transaction_id,
    expires,
  };
};

const verifyAndroidSubscription = async (
  packageName: string,
  productId: string,
  purchaseToken: string,
): Promise<{ ok: boolean; expiry?: Date }> => {
  const raw = Deno.env.get('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON');
  if (!raw) {
    return { ok: false };
  }
  let credentials: Record<string, unknown>;
  try {
    credentials = JSON.parse(raw) as Record<string, unknown>;
  } catch {
    return { ok: false };
  }

  const auth = new GoogleAuth({
    credentials,
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });
  const client = await auth.getClient();
  const access = await client.getAccessToken();
  if (!access.token) {
    return { ok: false };
  }

  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(packageName)}` +
    `/purchases/subscriptions/${encodeURIComponent(productId)}` +
    `/tokens/${encodeURIComponent(purchaseToken)}`;

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${access.token}` },
  });
  if (!res.ok) {
    return { ok: false };
  }
  const data = (await res.json()) as {
    paymentState?: number;
    expiryTimeMillis?: string;
  };
  const paymentOk = data.paymentState === 1 || data.paymentState === 2;
  const expiry = data.expiryTimeMillis
    ? new Date(Number(data.expiryTimeMillis))
    : undefined;
  return { ok: paymentOk, expiry };
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return handleOptions();
  }

  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  try {
    const user = await requireUser(req);
    const profile = await adminClient
      .from('security_cg_profiles')
      .select('id,company_id,role')
      .eq('id', user.id)
      .single();

    if (profile.error || !profile.data) {
      return json({ error: 'Profile not found' }, 404);
    }

    if (profile.data.role !== 'admin') {
      return json({ error: 'Only admins can activate subscriptions' }, 403);
    }

    const companyId = profile.data.company_id as string;
    const payload = await req.json();
    const platform = String(payload?.platform ?? '').toLowerCase();

    if (platform === 'ios') {
      const receipt = String(payload?.receipt_data ?? '').trim();
      if (!receipt) {
        return json({ error: 'receipt_data required' }, 400);
      }
      const apple = await verifyAppleReceipt(receipt);
      if (!apple.ok || !apple.productId) {
        return json({ error: 'Invalid or expired App Store receipt' }, 400);
      }
      const seats = seatsForProduct(apple.productId);
      const periodEnd = apple.expires?.toISOString() ?? null;
      const billingInterval = apple.productId?.toLowerCase().includes('year')
        ? 'year'
        : 'month';

      await adminClient.from('security_cg_subscriptions').upsert(
        {
          user_id: user.id,
          company_id: companyId,
          plan: 'flex',
          status: 'active',
          licensed_seats: seats,
          billing_interval: billingInterval,
          billing_provider: 'app_store',
          store_original_transaction_id: apple.originalTx ?? null,
          current_period_end: periodEnd,
          stripe_customer_id: null,
          stripe_subscription_id: null,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'company_id' },
      );

      return json({ ok: true, billing_provider: 'app_store', licensed_seats: seats });
    }

    if (platform === 'android') {
      const packageName = String(
        payload?.package_name ?? Deno.env.get('ANDROID_PACKAGE_NAME') ?? 'com.example.sass_security',
      ).trim();
      const productId = String(payload?.product_id ?? '').trim();
      const purchaseToken = String(payload?.purchase_token ?? '').trim();
      if (!productId || !purchaseToken) {
        return json({ error: 'product_id and purchase_token required' }, 400);
      }

      const play = await verifyAndroidSubscription(packageName, productId, purchaseToken);
      if (!play.ok) {
        return json(
          {
            error:
              'Play Store verification failed. Set GOOGLE_PLAY_SERVICE_ACCOUNT_JSON and ensure the subscription is active.',
          },
          400,
        );
      }

      const seats = seatsForProduct(productId);
      const periodEnd = play.expiry?.toISOString() ?? null;
      const billingInterval = productId.toLowerCase().includes('year') ? 'year' : 'month';

      await adminClient.from('security_cg_subscriptions').upsert(
        {
          user_id: user.id,
          company_id: companyId,
          plan: 'flex',
          status: 'active',
          licensed_seats: seats,
          billing_interval: billingInterval,
          billing_provider: 'play_store',
          store_original_transaction_id: purchaseToken.slice(0, 120),
          current_period_end: periodEnd,
          stripe_customer_id: null,
          stripe_subscription_id: null,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'company_id' },
      );

      return json({ ok: true, billing_provider: 'play_store', licensed_seats: seats });
    }

    return json({ error: 'platform must be ios or android' }, 400);
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : 'Unexpected error',
      },
      400,
    );
  }
});
