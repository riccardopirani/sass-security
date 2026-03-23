import '../../auth/models/app_profile.dart';

class EmployeeRecord {
  const EmployeeRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.riskScore,
    required this.trainingCompletion,
  });

  final String id;
  final String name;
  final String email;
  final AppUserRole role;
  final int riskScore;
  final int trainingCompletion;

  factory EmployeeRecord.fromMap(Map<String, dynamic> map) {
    return EmployeeRecord(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      role: roleFromString((map['role'] as String?) ?? 'employee'),
      riskScore: (map['risk_score'] as num?)?.toInt() ?? 0,
      trainingCompletion: (map['training_completion'] as num?)?.toInt() ?? 0,
    );
  }
}
