import { adminClient } from './supabase.ts';

export type ProfileRole = 'admin' | 'employee' | 'security_manager' | 'auditor';

export type AppProfile = {
  id: string;
  company_id: string;
  role: ProfileRole;
  name: string;
  email: string;
};

export const getProfileOrThrow = async (userId: string): Promise<AppProfile> => {
  const profile = await adminClient
    .from('security_cg_profiles')
    .select('id,company_id,role,name,email')
    .eq('id', userId)
    .single();

  if (profile.error || !profile.data) {
    throw new Error('Profile not found');
  }

  return profile.data as AppProfile;
};

export const isManagerRole = (role: ProfileRole) =>
  role === 'admin' || role === 'security_manager';

export const assertManagerRole = (role: ProfileRole) => {
  if (!isManagerRole(role)) {
    throw new Error('Only admin/security manager can perform this action.');
  }
};

