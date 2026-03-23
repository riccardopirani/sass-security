import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/models/app_profile.dart';
import '../models/employee_record.dart';

class EmployeeRepository {
  EmployeeRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<EmployeeRecord>> listByCompany(String companyId) async {
    final rows = await _client
        .from('employees')
        .select('id,name,email,role,risk_score,training_completion')
        .eq('company_id', companyId)
        .order('risk_score', ascending: false);

    return (rows as List)
        .map((row) => EmployeeRecord.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String companyId,
    required String name,
    required String email,
    required AppUserRole role,
    int riskScore = 0,
    int trainingCompletion = 0,
  }) async {
    await _client.from('employees').insert({
      'company_id': companyId,
      'name': name,
      'email': email,
      'role': roleToString(role),
      'risk_score': riskScore,
      'training_completion': trainingCompletion,
    });
  }

  Future<void> update({
    required String employeeId,
    required String name,
    required String email,
    required AppUserRole role,
    required int riskScore,
    required int trainingCompletion,
  }) async {
    await _client
        .from('employees')
        .update({
          'name': name,
          'email': email,
          'role': roleToString(role),
          'risk_score': riskScore,
          'training_completion': trainingCompletion,
        })
        .eq('id', employeeId);
  }

  Future<void> delete(String employeeId) async {
    await _client.from('employees').delete().eq('id', employeeId);
  }
}
