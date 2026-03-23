import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/models/app_profile.dart';
import '../data/alerts_repository.dart';
import '../models/alert_item.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final _repo = AlertsRepository();
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  var _incidentType = 'virus';
  var _severity = 'high';
  var _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitIncident() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleCtrl.text.trim();
    final details = _detailsCtrl.text.trim();

    if (title.isEmpty || details.isEmpty) {
      AppSnack.error(context, l10n.error_generic);
      return;
    }

    setState(() => _sending = true);
    try {
      await _repo.reportSecurityIncident(
        incidentType: _incidentType,
        severity: _severity,
        title: title,
        details: details,
      );
      _titleCtrl.clear();
      _detailsCtrl.clear();
      if (mounted) {
        AppSnack.success(
          context,
          'Segnalazione inviata ed email inoltrata a tutta l\'azienda.',
        );
      }
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<AlertItem>>(
      stream: _repo.streamByCompany(widget.profile.companyId),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? const <AlertItem>[];
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Segnala virus o hacking registrato',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _incidentType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo di incidente',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'virus', child: Text('Virus')),
                      DropdownMenuItem(
                        value: 'hacking',
                        child: Text('Hacking'),
                      ),
                    ],
                    onChanged: _sending
                        ? null
                        : (value) => setState(() {
                            _incidentType = value ?? 'virus';
                          }),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _severity,
                    decoration: InputDecoration(labelText: l10n.severity),
                    items: [
                      DropdownMenuItem(value: 'high', child: Text(l10n.high)),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text(l10n.medium),
                      ),
                      DropdownMenuItem(value: 'low', child: Text(l10n.low)),
                    ],
                    onChanged: _sending
                        ? null
                        : (value) => setState(() {
                            _severity = value ?? 'high';
                          }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _titleCtrl,
                    enabled: !_sending,
                    decoration: const InputDecoration(labelText: 'Titolo'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _detailsCtrl,
                    enabled: !_sending,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Dettagli incidente',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _submitIncident,
                      child: Text(_sending ? l10n.loading : 'Invia alert'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator()),
            if (snapshot.hasError)
              Center(child: Text(snapshot.error.toString())),
            if (!snapshot.hasError &&
                snapshot.connectionState != ConnectionState.waiting &&
                alerts.isEmpty)
              EmptyState(
                title: l10n.empty_alerts,
                icon: Icons.notifications_none,
              ),
            ...alerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _severityColor(alert.severity),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(alert.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(alert.message),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _SeverityChip(severity: alert.severity),
                        if (!alert.isRead)
                          TextButton(
                            onPressed: () => _repo.markRead(alert.id),
                            child: Text(l10n.mark_read),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'high':
        return const Color(0xFFDC2626);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
      default:
        return const Color(0xFF10B981);
    }
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: severity == 'high'
            ? const Color(0x33DC2626)
            : severity == 'medium'
            ? const Color(0x33F59E0B)
            : const Color(0x3310B981),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(severity.toUpperCase()),
    );
  }
}
