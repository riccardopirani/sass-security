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
  final _templateACtrl = TextEditingController();
  final _templateBCtrl = TextEditingController();

  late Future<List<PhishingCampaign>> _future;
  var _sending = false;
  var _generating = false;
  var _useAi = true;
  var _abTest = true;
  var _campaignMode = 'manual';
  String? _selectedLibraryTemplateId;
  List<Map<String, dynamic>> _library = const [];

  @override
  void initState() {
    super.initState();
    _future = _service.listCampaigns(widget.profile.companyId);
    _loadLibrary();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _templateACtrl.dispose();
    _templateBCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    try {
      final items = await _service.listAttackLibrary(widget.profile.companyId);
      if (mounted) {
        setState(() {
          _library = items;
        });
      }
    } catch (_) {}
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.listCampaigns(widget.profile.companyId);
    });
  }

  Future<void> _generateAiTemplates() async {
    final l10n = AppLocalizations.of(context);
    if (_nameCtrl.text.trim().isEmpty) {
      AppSnack.error(context, l10n.error_generic);
      return;
    }

    setState(() => _generating = true);
    try {
      final generated = await _service.generateTemplates(
        scenario: _nameCtrl.text.trim(),
        targetRole: 'employee',
      );
      _templateACtrl.text =
          (generated['body_a'] as String?) ?? _templateACtrl.text;
      _templateBCtrl.text =
          (generated['body_b'] as String?) ?? _templateBCtrl.text;

      if (mounted) {
        AppSnack.success(context, 'AI templates generated');
      }
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }

  Future<void> _sendTest() async {
    final l10n = AppLocalizations.of(context);
    if (_nameCtrl.text.trim().isEmpty || _templateACtrl.text.trim().isEmpty) {
      AppSnack.error(context, l10n.error_generic);
      return;
    }

    setState(() => _sending = true);
    try {
      await _service.sendTestCampaign(
        campaignName: _nameCtrl.text.trim(),
        template: _templateACtrl.text.trim(),
        templateB: _templateBCtrl.text.trim(),
        useAi: _useAi,
        abTestEnabled: _abTest,
        campaignMode: _campaignMode,
      );
      if (mounted) {
        AppSnack.success(context, l10n.success);
      }
      _nameCtrl.clear();
      _templateACtrl.clear();
      _templateBCtrl.clear();
      setState(() {
        _selectedLibraryTemplateId = null;
      });
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

  void _applyLibraryTemplate(String? templateId) {
    setState(() {
      _selectedLibraryTemplateId = templateId;
    });

    if (templateId == null) {
      return;
    }

    final item = _library.firstWhere(
      (row) => row['id'] == templateId,
      orElse: () => const <String, dynamic>{},
    );
    final body = (item['body_template'] as String?)?.trim() ?? '';
    final name = (item['name'] as String?)?.trim() ?? '';
    if (body.isNotEmpty) {
      _templateACtrl.text = body;
      _templateBCtrl.text = '$body\n\nPlease confirm this request directly.';
    }
    if (name.isNotEmpty && _nameCtrl.text.trim().isEmpty) {
      _nameCtrl.text = name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!widget.profile.isManager) {
      return EmptyState(
        title: l10n.phishing,
        subtitle: 'Admin/Security Manager access required.',
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
                'AI Phishing Simulation Engine',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (_library.isNotEmpty)
                DropdownButtonFormField<String?>(
                  initialValue: _selectedLibraryTemplateId,
                  decoration: const InputDecoration(
                    labelText: 'Attack simulation library',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Custom'),
                    ),
                    ..._library.map(
                      (item) => DropdownMenuItem<String?>(
                        value: item['id'] as String?,
                        child: Text(
                          '${item['category'] as String? ?? 'custom'} - ${item['name'] as String? ?? 'template'}',
                        ),
                      ),
                    ),
                  ],
                  onChanged: _sending ? null : _applyLibraryTemplate,
                ),
              if (_library.isNotEmpty) const SizedBox(height: 10),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.campaign_name),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _templateACtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Template A (primary)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _templateBCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Template B (A/B test)',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Use AI'),
                    selected: _useAi,
                    onSelected: _sending
                        ? null
                        : (value) => setState(() => _useAi = value),
                  ),
                  FilterChip(
                    label: const Text('A/B test'),
                    selected: _abTest,
                    onSelected: _sending
                        ? null
                        : (value) => setState(() => _abTest = value),
                  ),
                  ChoiceChip(
                    label: const Text('Manual'),
                    selected: _campaignMode == 'manual',
                    onSelected: _sending
                        ? null
                        : (_) => setState(() => _campaignMode = 'manual'),
                  ),
                  ChoiceChip(
                    label: const Text('Automatic'),
                    selected: _campaignMode == 'automatic',
                    onSelected: _sending
                        ? null
                        : (_) => setState(() => _campaignMode = 'automatic'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: (_sending || _generating || !_useAi)
                        ? null
                        : _generateAiTemplates,
                    child: Text(_generating ? l10n.loading : 'Generate AI A/B'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _sending ? null : _sendTest,
                    child: Text(_sending ? l10n.loading : l10n.send_test),
                  ),
                ],
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
                          subtitle: Text(
                            '${campaign.status} · ${campaign.campaignMode} · ${campaign.generatedByAi ? 'AI' : 'manual'} · ${campaign.abTestEnabled ? 'A/B' : 'single'}',
                          ),
                          trailing: Text(
                            '${l10n.sent}: ${campaign.sentCount}  '
                            '${l10n.opened}: ${campaign.openedCount}  '
                            '${l10n.clicked}: ${campaign.clickedCount}  '
                            'Cred: ${campaign.credentialSubmittedCount}',
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.end,
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
