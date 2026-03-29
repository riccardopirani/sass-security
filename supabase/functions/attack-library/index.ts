import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { assertManagerRole, getProfileOrThrow } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return handleOptions();
  }

  try {
    const user = await requireUser(req);
    const profile = await getProfileOrThrow(user.id);

    if (req.method === 'GET') {
      const rows = await adminClient
        .from('security_cg_attack_library')
        .select('id,category,name,subject_line,body_template,company_id,created_at')
        .or(`company_id.is.null,company_id.eq.${profile.company_id}`)
        .order('created_at', { ascending: false })
        .limit(200);

      if (rows.error) {
        return json({ error: rows.error.message }, 400);
      }

      return json({ items: rows.data ?? [] });
    }

    if (req.method === 'POST') {
      assertManagerRole(profile.role);
      const body = await req.json();
      const category = (body?.category as string | undefined)?.trim() ?? 'custom';
      const name = (body?.name as string | undefined)?.trim();
      const subject = (body?.subject_line as string | undefined)?.trim();
      const template = (body?.body_template as string | undefined)?.trim();

      if (!name || !subject || !template) {
        return json({ error: 'name, subject_line and body_template are required' }, 400);
      }

      const inserted = await adminClient
        .from('security_cg_attack_library')
        .insert({
          company_id: profile.company_id,
          category,
          name,
          subject_line: subject,
          body_template: template,
          created_by: profile.id,
        })
        .select('id')
        .single();

      if (inserted.error || !inserted.data) {
        return json({ error: inserted.error?.message ?? 'Unable to create item' }, 400);
      }

      return json({ id: inserted.data.id });
    }

    return json({ error: 'Method not allowed' }, 405);
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});

