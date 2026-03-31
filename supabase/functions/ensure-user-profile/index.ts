/**
 * Idempotent profile bootstrap for users whose trigger row was missed.
 * Called by the Flutter app when fetchMyProfile returns no rows.
 */
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return handleOptions();
  }
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  try {
    const user = await requireUser(req);
    const uid = user.id;
    const email = user.email ?? '';

    // Check if profile already exists
    const existing = await adminClient
      .from('security_cg_profiles')
      .select('id,company_id,name,email,role')
      .eq('id', uid)
      .maybeSingle();

    if (existing.data) {
      return json({ ok: true, created: false });
    }

    // Read user metadata for onboarding
    const { data: authUser, error: authErr } = await adminClient.auth.admin.getUserById(uid);
    if (authErr || !authUser?.user) {
      return json({ error: 'User not found in auth' }, 404);
    }

    const meta = (authUser.user.user_metadata ?? {}) as Record<string, string | undefined>;
    const roleTxt = (meta.role ?? 'admin').toLowerCase();
    const companyName = meta.company_name?.trim() || 'CyberGuard Company';
    const companyCode = meta.company_code?.trim() || null;
    const displayName = meta.name?.trim() || email.split('@')[0];
    const onboardingMode = (meta.onboarding_mode ?? 'trial').toLowerCase();
    const selectedPlanTxt = (meta.selected_plan ?? 'flex').toLowerCase();

    const validRoles = ['admin', 'employee', 'security_manager', 'auditor'];
    const role = validRoles.includes(roleTxt) ? roleTxt : 'admin';

    const validPlans = ['flex', 'starter', 'pro', 'business'];
    const plan = validPlans.includes(selectedPlanTxt) ? selectedPlanTxt : 'flex';

    // Resolve or create company
    let companyId: string | null = null;

    if (role !== 'admin' && companyCode) {
      const companyRow = await adminClient
        .from('security_cg_companies')
        .select('id')
        .eq('code', companyCode.toUpperCase())
        .maybeSingle();
      companyId = companyRow.data?.id ?? null;
    }

    if (!companyId) {
      const created = await adminClient
        .from('security_cg_companies')
        .insert({ name: companyName })
        .select('id')
        .single();
      if (created.error || !created.data) {
        return json({ error: created.error?.message ?? 'Failed to create company' }, 500);
      }
      companyId = created.data.id as string;
    }

    // Insert profile
    await adminClient
      .from('security_cg_profiles')
      .upsert(
        { id: uid, company_id: companyId, name: displayName, email, role },
        { onConflict: 'id' },
      );

    // Insert employee
    await adminClient
      .from('security_cg_employees')
      .upsert(
        { company_id: companyId, auth_user_id: uid, name: displayName, email, role },
        { onConflict: 'company_id,email' },
      );

    // Insert subscription
    const subscriptionStatus =
      role === 'admin' && onboardingMode === 'trial'
        ? 'trialing'
        : role === 'admin' && onboardingMode === 'paid'
          ? 'pending_checkout'
          : 'inactive';

    const trialEnd =
      role === 'admin' && onboardingMode === 'trial'
        ? new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
        : null;

    await adminClient
      .from('security_cg_subscriptions')
      .upsert(
        {
          user_id: uid,
          company_id: companyId,
          plan,
          status: subscriptionStatus,
          current_period_end: trialEnd,
        },
        { onConflict: 'company_id', ignoreDuplicates: true },
      );

    return json({ ok: true, created: true });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});
