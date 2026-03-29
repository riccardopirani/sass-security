import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/security_event_item.dart';

class CompanionService {
  CompanionService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> fetchMyProfileData(String companyId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return <String, dynamic>{};
    }

    final employee = await _client
        .from('security_cg_employees')
        .select('id,name,risk_score,training_completion,mfa_enabled,force_mfa')
        .eq('company_id', companyId)
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (employee == null) {
      return <String, dynamic>{};
    }

    final employeeId = employee['id'] as String?;
    final eventsRows = employeeId == null
        ? const <dynamic>[]
        : await _client
              .from('security_cg_security_events')
              .select('id,event_kind,severity,status,details,created_at')
              .eq('company_id', companyId)
              .eq('employee_id', employeeId)
              .eq('status', 'open')
              .order('created_at', ascending: false)
              .limit(20);

    final trainingAssignments = employeeId == null
        ? const <dynamic>[]
        : await _client
              .from('security_cg_training_assignments')
              .select('id,trigger_reason,status,due_at,created_at')
              .eq('company_id', companyId)
              .eq('employee_id', employeeId)
              .neq('status', 'completed')
              .order('created_at', ascending: false)
              .limit(20);

    final events = (eventsRows as List)
        .map((row) => SecurityEventItem.fromMap(row as Map<String, dynamic>))
        .toList();

    return {
      'employee': employee,
      'events': events,
      'assignments': (trainingAssignments as List).cast<Map<String, dynamic>>(),
    };
  }

  Future<void> resolveSecurityEvent({
    required String eventId,
    required String action,
  }) async {
    await _client.functions.invoke(
      'resolve-security-event',
      body: {'eventId': eventId, 'action': action},
    );
  }

  Future<void> completeAssignment(String assignmentId) async {
    await _client
        .from('security_cg_training_assignments')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', assignmentId);
  }
}

