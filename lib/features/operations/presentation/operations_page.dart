import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/models/app_profile.dart';
import '../data/operations_service.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  final _service = OperationsService();
  final _copilotCtrl = TextEditingController();
  final _remediationEmployeeCtrl = TextEditingController();
  final _emailSenderCtrl = TextEditingController();
  final _emailSubjectCtrl = TextEditingController();
  final _emailBodyCtrl = TextEditingController();

  var _busy = false;
  String _copilotAnswer = '';
  String _benchmarkMessage = '';
  String _behaviorSummary = '';
  String _remediationSummary = '';
  String _emailScanSummary = '';
  String _reportSummary = '';

  @override
  void dispose() {
    _copilotCtrl.dispose();
    _remediationEmployeeCtrl.dispose();
    _emailSenderCtrl.dispose();
    _emailSubjectCtrl.dispose();
    _emailBodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _runCopilot() async {
    if (_copilotCtrl.text.trim().isEmpty) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final response = await _service.askCopilot(_copilotCtrl.text.trim());
      setState(() {
        _copilotAnswer =
            (response['answer'] as String?) ?? l10n.copilot_no_answer;
      });
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _loadBenchmarkAndBehavior() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final benchmark = await _service.fetchBenchmark();
      final behavior = await _service.fetchBehaviorProfile();

      setState(() {
        _benchmarkMessage = (benchmark['peer_message'] as String?) ??
            l10n.no_benchmark_data;
        final score = (behavior['behavior_risk_profile'] as num?)?.toInt() ?? 0;
        final samples = (behavior['samples'] as num?)?.toInt() ?? 0;
        _behaviorSummary = l10n.behavior_risk_profile_line(score, samples);
      });
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _suggestRemediation({required bool execute}) async {
    final l10n = AppLocalizations.of(context);
    final employeeId = _remediationEmployeeCtrl.text.trim();
    if (employeeId.isEmpty) {
      AppSnack.error(context, l10n.employee_id_required);
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await _service.suggestRemediation(
        employeeId: employeeId,
        execute: execute,
      );
      final suggested = (result['suggested_actions'] as List<dynamic>? ?? const [])
          .length;
      final executed = (result['executed_actions'] as List<dynamic>? ?? const [])
          .length;
      setState(() {
        _remediationSummary = l10n.remediation_summary_line(
          suggested,
          executed,
          (result['risk_score'] as num?)?.toInt() ?? 0,
        );
      });
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _scanEmail() async {
    final l10n = AppLocalizations.of(context);
    final sender = _emailSenderCtrl.text.trim();
    final subject = _emailSubjectCtrl.text.trim();
    final body = _emailBodyCtrl.text.trim();
    if (sender.isEmpty || subject.isEmpty || body.isEmpty) {
      AppSnack.error(context, l10n.email_fields_required);
      return;
    }

    setState(() => _busy = true);
    try {
      final result = await _service.scanEmail(
        sender: sender,
        subject: subject,
        body: body,
      );
      setState(() {
        _emailScanSummary = l10n.email_scan_summary_line(
          (result['risk_score'] as num?)?.toInt() ?? 0,
          '${result['severity'] ?? 'n/a'}',
        );
      });
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _generateReport() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final result = await _service.generateComplianceReport();
      final fileName =
          (result['file_name'] as String?) ?? 'cyberguard_compliance.pdf';
      final base64 = (result['pdf_base64'] as String?) ?? '';
      setState(() {
        _reportSummary = l10n.report_generated_summary(fileName, base64.length);
      });
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!widget.profile.isManager && !widget.profile.isAuditor) {
      return EmptyState(
        title: l10n.security_operations_title,
        subtitle: l10n.ops_access_required,
        icon: Icons.lock_outline,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.ai_copilot_title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _copilotCtrl,
                minLines: 1,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.copilot_hint,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _busy ? null : _runCopilot,
                  child: Text(l10n.ask_copilot),
                ),
              ),
              if (_copilotAnswer.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(_copilotAnswer),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.behavior_benchmark_section,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _busy ? null : _loadBenchmarkAndBehavior,
                child: Text(l10n.refresh_analytics),
              ),
              if (_benchmarkMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_benchmarkMessage),
              ],
              if (_behaviorSummary.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(_behaviorSummary),
              ],
            ],
          ),
        ),
        if (widget.profile.isManager) ...[
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.auto_remediation_title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _remediationEmployeeCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.employee_id,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _suggestRemediation(execute: false),
                      child: Text(l10n.suggest_actions),
                    ),
                    ElevatedButton(
                      onPressed: _busy
                          ? null
                          : () => _suggestRemediation(execute: true),
                      child: Text(l10n.execute_actions),
                    ),
                  ],
                ),
                if (_remediationSummary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_remediationSummary),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.email_security_layer_title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailSenderCtrl,
                  decoration: InputDecoration(labelText: l10n.sender_email),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailSubjectCtrl,
                  decoration: InputDecoration(labelText: l10n.subject_field),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailBodyCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.body_excerpt),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _busy ? null : _scanEmail,
                  child: Text(l10n.scan_email),
                ),
                if (_emailScanSummary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_emailScanSummary),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.audit_reports_title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _busy ? null : _generateReport,
                child: Text(l10n.generate_compliance_pdf),
              ),
              if (_reportSummary.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_reportSummary),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

