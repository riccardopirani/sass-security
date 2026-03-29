import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/employee_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../auth/models/app_profile.dart';
import '../data/companion_service.dart';
import '../models/security_event_item.dart';

class CompanionPage extends StatefulWidget {
  const CompanionPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage> {
  final _service = CompanionService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchMyProfileData(widget.profile.companyId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.fetchMyProfileData(widget.profile.companyId);
    });
  }

  Future<void> _resolveEvent(SecurityEventItem event, String action) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _service.resolveSecurityEvent(eventId: event.id, action: action);
      if (mounted) {
        AppSnack.success(context, l10n.action_applied);
      }
      await _reload();
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    }
  }

  Future<void> _completeAssignment(String assignmentId) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _service.completeAssignment(assignmentId);
      if (mounted) {
        AppSnack.success(context, l10n.training_marked_complete);
      }
      await _reload();
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingSkeleton(height: 120),
              SizedBox(height: 12),
              LoadingSkeleton(height: 120),
            ],
          );
        }

        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(snapshot.error.toString()),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _reload, child: Text(l10n.refresh)),
            ],
          );
        }

        final data = snapshot.data ?? const <String, dynamic>{};
        final employee = data['employee'] as Map<String, dynamic>?;
        if (employee == null) {
          return EmptyState(
            title: l10n.companion_title,
            subtitle: l10n.companion_no_employee,
            icon: Icons.phone_android_outlined,
          );
        }

        final name = (employee['name'] as String?) ?? l10n.unknown;
        final avatarUrl = employee['avatar_url'] as String?;
        final events = (data['events'] as List<SecurityEventItem>? ?? const []);
        final assignments =
            (data['assignments'] as List<Map<String, dynamic>>? ?? const []);

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.companion_title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EmployeeAvatar(
                          name: name,
                          imageUrl: avatarUrl,
                          radius: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.companion_user}: $name',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${l10n.companion_risk_score}: ${employee['risk_score'] ?? 0}/100',
                              ),
                              Text(
                                '${l10n.companion_training}: ${employee['training_completion'] ?? 0}%',
                              ),
                              Text(
                                '${l10n.mfa_enabled_label}: ${(employee['mfa_enabled'] ?? false) ? l10n.yes : l10n.no}',
                              ),
                              Text(
                                '${l10n.force_mfa_login}: ${(employee['force_mfa'] ?? false) ? l10n.yes : l10n.no}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.suspicious_activity,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (events.isEmpty)
                      Text(l10n.no_open_suspicious),
                    ...events.map(
                      (event) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF334155)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${event.eventKind} · ${event.severity.toUpperCase()}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(event.details),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton(
                                  onPressed: () =>
                                      _resolveEvent(event, 'approve'),
                                  child: Text(l10n.approve),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      _resolveEvent(event, 'block'),
                                  child: Text(l10n.block),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.adaptive_learning,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (assignments.isEmpty)
                      Text(l10n.no_training_assignments),
                    ...assignments.map(
                      (assignment) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${l10n.training_label}: ${assignment['trigger_reason'] ?? 'general'}',
                        ),
                        subtitle: Text(
                          '${l10n.assignment_status}: ${assignment['status'] ?? 'assigned'}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () =>
                              _completeAssignment(assignment['id'] as String),
                          child: Text(l10n.complete),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
