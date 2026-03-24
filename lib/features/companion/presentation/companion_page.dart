import 'package:flutter/material.dart';

import '../../../core/utils/app_snack.dart';
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
    try {
      await _service.resolveSecurityEvent(eventId: event.id, action: action);
      if (mounted) {
        AppSnack.success(context, 'Action applied');
      }
      await _reload();
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    }
  }

  Future<void> _completeAssignment(String assignmentId) async {
    try {
      await _service.completeAssignment(assignmentId);
      if (mounted) {
        AppSnack.success(context, 'Training marked as completed');
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
              ElevatedButton(onPressed: _reload, child: const Text('Refresh')),
            ],
          );
        }

        final data = snapshot.data ?? const <String, dynamic>{};
        final employee = data['employee'] as Map<String, dynamic>?;
        if (employee == null) {
          return const EmptyState(
            title: 'Mobile Security Companion',
            subtitle: 'No linked employee profile found.',
            icon: Icons.phone_android_outlined,
          );
        }

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
                      'Mobile Security Companion',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text('User: ${employee['name'] ?? 'Unknown'}'),
                    Text('Risk score: ${employee['risk_score'] ?? 0}/100'),
                    Text(
                      'Training completion: ${employee['training_completion'] ?? 0}%',
                    ),
                    Text('MFA enabled: ${(employee['mfa_enabled'] ?? false) ? 'Yes' : 'No'}'),
                    Text('Force MFA: ${(employee['force_mfa'] ?? false) ? 'Yes' : 'No'}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suspicious activity actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (events.isEmpty)
                      const Text('No open suspicious activity.'),
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
                                  onPressed: () => _resolveEvent(event, 'approve'),
                                  child: const Text('Approve'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _resolveEvent(event, 'block'),
                                  child: const Text('Block'),
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
                      'Adaptive micro-learning',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (assignments.isEmpty)
                      const Text('No active training assignments.'),
                    ...assignments.map(
                      (assignment) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Training: ${assignment['trigger_reason'] ?? 'general'}',
                        ),
                        subtitle: Text('Status: ${assignment['status'] ?? 'assigned'}'),
                        trailing: ElevatedButton(
                          onPressed: () =>
                              _completeAssignment(assignment['id'] as String),
                          child: const Text('Complete'),
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

