import 'package:supabase_flutter/supabase_flutter.dart';

class OperationsService {
  OperationsService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> askCopilot(String question) async {
    final response = await _client.functions.invoke(
      'security-copilot',
      body: {'question': question},
    );
    return (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchBenchmark() async {
    final response = await _client.functions.invoke('company-benchmark');
    return (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchBehaviorProfile({
    String? employeeId,
  }) async {
    final response = await _client.functions.invoke(
      'behavior-profile',
      body: {
        if (employeeId != null && employeeId.trim().isNotEmpty)
          'employeeId': employeeId.trim(),
      },
    );
    return (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> suggestRemediation({
    required String employeeId,
    bool execute = false,
  }) async {
    final response = await _client.functions.invoke(
      'auto-remediation',
      body: {'employeeId': employeeId, 'execute': execute},
    );
    return (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> generateComplianceReport() async {
    final response = await _client.functions.invoke(
      'generate-compliance-report',
    );
    return (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> dispatchThreatAlert({
    required String title,
    required String message,
    String severity = 'high',
  }) async {
    final response = await _client.functions.invoke(
      'dispatch-threat-alert',
      body: {'title': title, 'message': message, 'severity': severity},
    );
    return (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> scanEmail({
    required String sender,
    required String subject,
    required String body,
    String? employeeId,
  }) async {
    final response = await _client.functions.invoke(
      'scan-email-security',
      body: {
        'sender': sender,
        'subject': subject,
        'body': body,
        if (employeeId != null && employeeId.trim().isNotEmpty)
          'employeeId': employeeId.trim(),
      },
    );
    return (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};
  }
}
