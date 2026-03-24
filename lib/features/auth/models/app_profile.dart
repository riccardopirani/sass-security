enum AppUserRole { admin, securityManager, employee, auditor }

AppUserRole roleFromString(String value) {
  switch (value) {
    case 'admin':
      return AppUserRole.admin;
    case 'security_manager':
      return AppUserRole.securityManager;
    case 'auditor':
      return AppUserRole.auditor;
    case 'employee':
    default:
      return AppUserRole.employee;
  }
}

String roleToString(AppUserRole role) {
  switch (role) {
    case AppUserRole.admin:
      return 'admin';
    case AppUserRole.securityManager:
      return 'security_manager';
    case AppUserRole.employee:
      return 'employee';
    case AppUserRole.auditor:
      return 'auditor';
  }
}

class AppProfile {
  const AppProfile({
    required this.id,
    required this.companyId,
    required this.name,
    required this.email,
    required this.role,
    required this.riskScore,
    this.companyName,
    this.companyCode,
  });

  final String id;
  final String companyId;
  final String name;
  final String email;
  final AppUserRole role;
  final int riskScore;
  final String? companyName;
  final String? companyCode;

  bool get isAdmin => role == AppUserRole.admin;
  bool get isManager =>
      role == AppUserRole.admin || role == AppUserRole.securityManager;
  bool get isAuditor => role == AppUserRole.auditor;

  factory AppProfile.fromMap(Map<String, dynamic> map) {
    final companyMap = map['companies'] as Map<String, dynamic>?;

    return AppProfile(
      id: map['id'] as String,
      companyId: map['company_id'] as String,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      role: roleFromString((map['role'] as String?) ?? 'employee'),
      riskScore: (map['risk_score'] as num?)?.toInt() ?? 0,
      companyName: companyMap?['name'] as String?,
      companyCode: companyMap?['code'] as String?,
    );
  }
}
