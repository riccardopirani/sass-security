import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/models/app_profile.dart';
import '../data/subscription_service.dart';
import '../models/subscription_record.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final _service = SubscriptionService();
  late Future<SubscriptionRecord?> _future;
  String? _loadingPlan;

  @override
  void initState() {
    super.initState();
    _future = _service.currentForCompany(widget.profile.companyId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.currentForCompany(widget.profile.companyId);
    });
  }

  Future<void> _subscribe(String plan) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _loadingPlan = plan);
    try {
      await _service.openCheckout(plan);
      if (mounted) {
        AppSnack.success(context, l10n.subscription_updated);
      }
      await _reload();
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loadingPlan = null);
      }
    }
  }

  Future<void> _manage() async {
    final l10n = AppLocalizations.of(context);
    try {
      await _service.openBillingPortal();
      if (mounted) {
        AppSnack.success(context, l10n.billing);
      }
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<SubscriptionRecord?>(
      future: _future,
      builder: (context, snapshot) {
        final current = snapshot.data;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.pricing,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.current_plan}: ${current?.plan ?? l10n.unknown}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            if (current != null) ...[
              const SizedBox(height: 4),
              Text('${l10n.status}: ${current.status}'),
            ],
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 980;
                final cardWidth = wide
                    ? (constraints.maxWidth - 24) / 3
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _PlanCard(
                      width: cardWidth,
                      planCode: 'starter',
                      title: l10n.starter,
                      description: l10n.plan_starter_desc,
                      price: '\$29/${l10n.per_month}',
                      highlighted: current?.plan == 'starter',
                      loading: _loadingPlan == 'starter',
                      onSubscribe: () => _subscribe('starter'),
                    ),
                    _PlanCard(
                      width: cardWidth,
                      planCode: 'pro',
                      title: l10n.pro,
                      description: l10n.plan_pro_desc,
                      price: '\$79/${l10n.per_month}',
                      highlighted: current?.plan == 'pro',
                      loading: _loadingPlan == 'pro',
                      onSubscribe: () => _subscribe('pro'),
                    ),
                    _PlanCard(
                      width: cardWidth,
                      planCode: 'business',
                      title: l10n.business,
                      description: l10n.plan_business_desc,
                      price: '\$199/${l10n.per_month}',
                      highlighted: current?.plan == 'business',
                      loading: _loadingPlan == 'business',
                      onSubscribe: () => _subscribe('business'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: _manage,
                child: Text(l10n.manage_subscription),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.width,
    required this.planCode,
    required this.title,
    required this.description,
    required this.price,
    required this.highlighted,
    required this.loading,
    required this.onSubscribe,
  });

  final double width;
  final String planCode;
  final String title;
  final String description;
  final String price;
  final bool highlighted;
  final bool loading;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: width,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Text(price, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : onSubscribe,
                child: Text(highlighted ? l10n.current_plan : l10n.upgrade),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
