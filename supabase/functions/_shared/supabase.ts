import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';

if (!supabaseUrl || !serviceRoleKey || !anonKey) {
  throw new Error('Supabase function env vars are missing.');
}

export const adminClient = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

export const userClient = (authorization: string) =>
  createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false },
    global: {
      headers: {
        Authorization: authorization,
      },
    },
  });

export const requireUser = async (req: Request) => {
  const authorization = req.headers.get('Authorization');
  if (!authorization) {
    throw new Error('Missing Authorization header.');
  }

  const client = userClient(authorization);
  const {
    data: { user },
    error,
  } = await client.auth.getUser();

  if (error || !user) {
    throw new Error('Unauthorized');
  }

  return user;
};
