import 'package:flutter/material.dart';

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
    setState(() => _busy = true);
    try {
      final response = await _service.askCopilot(_copilotCtrl.text.trim());
      setState(() {
        _copilotAnswer = (response['answer'] as String?) ?? 'No answer.';
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
    setState(() => _busy = true);
    try {
      final benchmark = await _service.fetchBenchmark();
      final behavior = await _service.fetchBehaviorProfile();

      setState(() {
        _benchmarkMessage =
            (benchmark['peer_message'] as String?) ?? 'No benchmark data.';
        _behaviorSummary =
            'Behavior risk profile: ${behavior['behavior_risk_profile'] ?? 0}/100 '
            '(samples: ${behavior['samples'] ?? 0})';
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
    final employeeId = _remediationEmployeeCtrl.text.trim();
    if (employeeId.isEmpty) {
      AppSnack.error(context, 'Employee ID is required');
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
        _remediationSummary =
            'Suggested: $suggested | Executed: $executed | Risk: ${result['risk_score'] ?? 0}';
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
    final sender = _emailSenderCtrl.text.trim();
    final subject = _emailSubjectCtrl.text.trim();
    final body = _emailBodyCtrl.text.trim();
    if (sender.isEmpty || subject.isEmpty || body.isEmpty) {
      AppSnack.error(context, 'Sender, subject and body are required');
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
        _emailScanSummary =
            'Risk score: ${result['risk_score'] ?? 0} | Severity: ${result['severity'] ?? 'n/a'}';
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
    setState(() => _busy = true);
    try {
      final result = await _service.generateComplianceReport();
      final fileName =
          (result['file_name'] as String?) ?? 'cyberguard_compliance.pdf';
      final base64 = (result['pdf_base64'] as String?) ?? '';
      setState(() {
        _reportSummary =
            'Generated: $fileName | PDF payload size: ${base64.length} chars';
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
    if (!widget.profile.isManager && !widget.profile.isAuditor) {
      return const EmptyState(
        title: 'Security Operations',
        subtitle: 'Manager or Auditor access required.',
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
                'AI Security Copilot',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _copilotCtrl,
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ask: "Questo evento è pericoloso?"',
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _busy ? null : _runCopilot,
                  child: const Text('Ask Copilot'),
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
                'Behavior Analytics + Benchmark',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _busy ? null : _loadBenchmarkAndBehavior,
                child: const Text('Refresh analytics'),
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
                  'Auto-remediation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _remediationEmployeeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
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
                      child: const Text('Suggest actions'),
                    ),
                    ElevatedButton(
                      onPressed: _busy
                          ? null
                          : () => _suggestRemediation(execute: true),
                      child: const Text('Execute actions'),
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
                  'Email Security Layer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailSenderCtrl,
                  decoration: const InputDecoration(labelText: 'Sender email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailSubjectCtrl,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailBodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Body excerpt'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _busy ? null : _scanEmail,
                  child: const Text('Scan email'),
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
                'Audit & Compliance Reports',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _busy ? null : _generateReport,
                child: const Text('Generate GDPR/Security PDF'),
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

