import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../auth/models/app_profile.dart';
import '../data/phishing_service.dart';
import '../models/phishing_campaign.dart';

class PhishingPage extends StatefulWidget {
  const PhishingPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<PhishingPage> createState() => _PhishingPageState();
}

class _PhishingPageState extends State<PhishingPage> {
  final _service = PhishingService();
  final _nameCtrl = TextEditingController();
  final _templateCtrl = TextEditingController();

  late Future<List<PhishingCampaign>> _future;
  var _sending = false;

  @override
  void initState() {
    super.initState();
    _future = _service.listCampaigns(widget.profile.companyId);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _templateCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.listCampaigns(widget.profile.companyId);
    });
  }

  Future<void> _sendTest() async {
    final l10n = AppLocalizations.of(context);
    if (_nameCtrl.text.trim().isEmpty || _templateCtrl.text.trim().isEmpty) {
      AppSnack.error(context, l10n.error_generic);
      return;
    }

    setState(() => _sending = true);
    try {
      await _service.sendTestCampaign(
        campaignName: _nameCtrl.text.trim(),
        template: _templateCtrl.text.trim(),
      );
      if (mounted) {
        AppSnack.success(context, l10n.success);
      }
      _nameCtrl.clear();
      _templateCtrl.clear();
      await _reload();
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

    if (!widget.profile.isAdmin) {
      return EmptyState(
        title: l10n.phishing,
        subtitle: 'Admin access required.',
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
                l10n.create_campaign,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.campaign_name),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _templateCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.campaign_template),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _sending ? null : _sendTest,
                  child: Text(l10n.send_test),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<PhishingCampaign>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Column(
                children: [
                  LoadingSkeleton(height: 88),
                  SizedBox(height: 10),
                  LoadingSkeleton(height: 88),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: _reload, child: Text(l10n.refresh)),
                ],
              );
            }

            final campaigns = snapshot.data ?? const <PhishingCampaign>[];
            if (campaigns.isEmpty) {
              return EmptyState(
                title: l10n.no_campaigns,
                icon: Icons.email_outlined,
              );
            }

            return Column(
              children: campaigns
                  .map(
                    (campaign) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(campaign.name),
                          subtitle: Text(campaign.status),
                          trailing: Text(
                            '${l10n.sent}: ${campaign.sentCount}  ${l10n.opened}: ${campaign.openedCount}  ${l10n.clicked}: ${campaign.clickedCount}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
