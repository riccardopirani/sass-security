import 'package:supabase_flutter/supabase_flutter.dart';

class OrgService {
  OrgService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> listDepartments(String companyId) async {
    final rows = await _client
        .from('security_cg_departments')
        .select('id,name,created_at')
        .eq('company_id', companyId)
        .order('name', ascending: true);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listTeams(String companyId) async {
    final rows = await _client
        .from('security_cg_teams')
        .select('id,name,department_id,created_at')
        .eq('company_id', companyId)
        .order('name', ascending: true);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> createDepartment({
    required String companyId,
    required String name,
  }) async {
    await _client.from('security_cg_departments').insert({
      'company_id': companyId,
      'name': name.trim(),
    });
  }

  Future<void> createTeam({
    required String companyId,
    required String name,
    String? departmentId,
  }) async {
    await _client.from('security_cg_teams').insert({
      'company_id': companyId,
      'name': name.trim(),
      'department_id': departmentId,
    });
  }
}

