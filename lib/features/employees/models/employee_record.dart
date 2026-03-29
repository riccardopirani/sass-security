import '../../auth/models/app_profile.dart';

class EmployeeRecord {
  const EmployeeRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.riskScore,
    required this.trainingCompletion,
    required this.passwordBehaviorScore,
    required this.incidentHistoryScore,
    required this.deviceComplianceScore,
    required this.behaviorRiskScore,
    required this.mfaEnabled,
    required this.forceMfa,
    this.departmentId,
    this.teamId,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final AppUserRole role;
  final int riskScore;
  final int trainingCompletion;
  final int passwordBehaviorScore;
  final int incidentHistoryScore;
  final int deviceComplianceScore;
  final int behaviorRiskScore;
  final bool mfaEnabled;
  final bool forceMfa;
  final String? departmentId;
  final String? teamId;
  final String? avatarUrl;

  factory EmployeeRecord.fromMap(Map<String, dynamic> map) {
    return EmployeeRecord(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      role: roleFromString((map['role'] as String?) ?? 'employee'),
      riskScore: (map['risk_score'] as num?)?.toInt() ?? 0,
      trainingCompletion: (map['training_completion'] as num?)?.toInt() ?? 0,
      passwordBehaviorScore:
          (map['password_behavior_score'] as num?)?.toInt() ?? 30,
      incidentHistoryScore:
          (map['incident_history_score'] as num?)?.toInt() ?? 0,
      deviceComplianceScore:
          (map['device_compliance_score'] as num?)?.toInt() ?? 25,
      behaviorRiskScore: (map['behavior_risk_score'] as num?)?.toInt() ?? 15,
      mfaEnabled: (map['mfa_enabled'] as bool?) ?? false,
      forceMfa: (map['force_mfa'] as bool?) ?? false,
      departmentId: map['department_id'] as String?,
      teamId: map['team_id'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}
