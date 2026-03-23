import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/alert_item.dart';

class AlertsRepository {
  AlertsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Stream<List<AlertItem>> streamByCompany(String companyId) {
    return _client
        .from('cg_alerts')
        .stream(primaryKey: ['id'])
        .eq('company_id', companyId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((row) => AlertItem.fromMap(row)).toList());
  }

  Future<void> markRead(String alertId) async {
    await _client.from('cg_alerts').update({'is_read': true}).eq('id', alertId);
  }

  Future<void> reportSecurityIncident({
    required String incidentType,
    required String severity,
    required String title,
    required String details,
  }) async {
    await _client.functions.invoke(
      'report-security-alert',
      body: {
        'incidentType': incidentType,
        'severity': severity,
        'title': title,
        'details': details,
      },
    );
  }
}
