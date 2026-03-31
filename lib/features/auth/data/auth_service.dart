import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_profile.dart';

class AuthService {
  AuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required AppUserRole role,
    String onboardingMode = 'trial',
    String selectedPlan = 'flex',
    String? companyName,
    String? companyCode,
  }) async {
    if (role == AppUserRole.admin &&
        (companyName == null || companyName.trim().isEmpty)) {
      throw const AuthException('Company name is required for admin sign-up.');
    }
    if (role != AppUserRole.admin &&
        (companyCode == null || companyCode.trim().isEmpty)) {
      throw const AuthException(
        'Company code is required for non-admin sign-up.',
      );
    }

    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': roleToString(role),
        'onboarding_mode': onboardingMode,
        'selected_plan': selectedPlan,
        if (companyName != null) 'company_name': companyName,
        if (companyCode != null) 'company_code': companyCode,
      },
    );
  }

  Future<AppProfile> fetchMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('No active user session.');
    }

    // Attempt to fetch the profile; if absent, trigger idempotent repair.
    Map<String, dynamic>? result = await _client
        .from('security_cg_profiles')
        .select(
          'id,company_id,name,email,role,risk_score,companies:security_cg_companies!company_id(name,code)',
        )
        .eq('id', user.id)
        .maybeSingle();

    if (result == null) {
      // Profile missing – call the repair edge function and retry once.
      await _client.functions.invoke('ensure-user-profile');
      result = await _client
          .from('security_cg_profiles')
          .select(
            'id,company_id,name,email,role,risk_score,companies:security_cg_companies!company_id(name,code)',
          )
          .eq('id', user.id)
          .single();
    }

    final empAvatar = await _client
        .from('security_cg_employees')
        .select('avatar_url')
        .eq('auth_user_id', user.id)
        .maybeSingle();

    final merged = Map<String, dynamic>.from(result);
    if (empAvatar != null && empAvatar['avatar_url'] != null) {
      merged['avatar_url'] = empAvatar['avatar_url'];
    }

    return AppProfile.fromMap(merged);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
