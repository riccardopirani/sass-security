import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { getProfileOrThrow } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

const companySelect =
  'id,name,risk_score,benchmark_percentile,industry,company_size,region';
const companyFallbackSelect = 'id,name,risk_score';

const fetchCompanyWithBenchmarkFallback = async (companyId: string) => {
  const company = await adminClient
    .from('security_cg_companies')
    .select(companySelect)
    .eq('id', companyId)
    .single();

  if (company.error?.code !== '42703') {
    return company;
  }

  const fallback = await adminClient
    .from('security_cg_companies')
    .select(companyFallbackSelect)
    .eq('id', companyId)
    .single();

  return {
    data:
      fallback.data == null
        ? null
        : {
            ...fallback.data,
            benchmark_percentile: 0,
            industry: 'general',
            company_size: 'smb',
            region: 'global',
          },
    error: fallback.error,
  };
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
    const profile = await getProfileOrThrow(user.id);

    await adminClient.rpc('refresh_company_benchmark', {
      target_company: profile.company_id,
    });

    const company = await fetchCompanyWithBenchmarkFallback(profile.company_id);

    if (company.error || !company.data) {
      return json({ error: 'Company not found' }, 404);
    }

    const trend = await adminClient
      .from('security_cg_company_score_snapshots')
      .select('snapshot_date,risk_score')
      .eq('company_id', profile.company_id)
      .order('snapshot_date', { ascending: false })
      .limit(30);

    const percentile = (company.data.benchmark_percentile as number | null) ?? 0;

    return json({
      company: company.data,
      peer_message: `Your company is safer than ${percentile}% of peers.`,
      trend: trend.data ?? [],
    });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});
