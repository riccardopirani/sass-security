import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/models/app_profile.dart';
import '../data/alerts_repository.dart';
import '../models/alert_item.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = AlertsRepository();

    return StreamBuilder<List<AlertItem>>(
      stream: repo.streamByCompany(profile.companyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final alerts = snapshot.data ?? const <AlertItem>[];
        if (alerts.isEmpty) {
          return EmptyState(
            title: l10n.empty_alerts,
            icon: Icons.notifications_none,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: alerts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return GlassCard(
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
                        onPressed: () => repo.markRead(alert.id),
                        child: Text(l10n.mark_read),
                      ),
                  ],
                ),
              ),
            );
          },
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
