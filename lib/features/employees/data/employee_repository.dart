import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/models/app_profile.dart';
import '../models/employee_record.dart';

class EmployeeRepository {
  EmployeeRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<EmployeeRecord>> listByCompany(String companyId) async {
    final rows = await _client
        .from('cg_employees')
        .select(
          'id,name,email,role,risk_score,training_completion,password_behavior_score,incident_history_score,device_compliance_score,behavior_risk_score,mfa_enabled,force_mfa,department_id,team_id',
        )
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
    int passwordBehaviorScore = 30,
    int incidentHistoryScore = 0,
    int deviceComplianceScore = 25,
    int behaviorRiskScore = 15,
    bool mfaEnabled = false,
    bool forceMfa = false,
    String? departmentId,
    String? teamId,
  }) async {
    await _client.from('cg_employees').insert({
      'company_id': companyId,
      'name': name,
      'email': email,
      'role': roleToString(role),
      'risk_score': riskScore,
      'training_completion': trainingCompletion,
      'password_behavior_score': passwordBehaviorScore,
      'incident_history_score': incidentHistoryScore,
      'device_compliance_score': deviceComplianceScore,
      'behavior_risk_score': behaviorRiskScore,
      'mfa_enabled': mfaEnabled,
      'force_mfa': forceMfa,
      'department_id': departmentId,
      'team_id': teamId,
    });
  }

  Future<void> update({
    required String employeeId,
    required String name,
    required String email,
    required AppUserRole role,
    required int riskScore,
    required int trainingCompletion,
    required int passwordBehaviorScore,
    required int incidentHistoryScore,
    required int deviceComplianceScore,
    required int behaviorRiskScore,
    required bool mfaEnabled,
    required bool forceMfa,
    String? departmentId,
    String? teamId,
  }) async {
    await _client
        .from('cg_employees')
        .update({
          'name': name,
          'email': email,
          'role': roleToString(role),
          'risk_score': riskScore,
          'training_completion': trainingCompletion,
          'password_behavior_score': passwordBehaviorScore,
          'incident_history_score': incidentHistoryScore,
          'device_compliance_score': deviceComplianceScore,
          'behavior_risk_score': behaviorRiskScore,
          'mfa_enabled': mfaEnabled,
          'force_mfa': forceMfa,
          'department_id': departmentId,
          'team_id': teamId,
        })
        .eq('id', employeeId);
  }

  Future<void> delete(String employeeId) async {
    await _client.from('cg_employees').delete().eq('id', employeeId);
  }
}
