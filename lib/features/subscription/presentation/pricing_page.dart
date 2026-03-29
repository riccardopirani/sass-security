import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sass_security/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/pricing/subscription_price.dart';
import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/models/app_profile.dart';
import '../data/subscription_service.dart';
import '../models/invoice_history_item.dart';
import '../models/subscription_record.dart';

class _SubPageData {
  _SubPageData(this.subscription, this.riskScore, this.invoices);

  final SubscriptionRecord? subscription;
  final int riskScore;
  final List<InvoiceHistoryItem> invoices;
}

class PricingPage extends StatefulWidget {
  const PricingPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final _service = SubscriptionService();
  final _usersCtrl = TextEditingController(text: '5');
  late Future<_SubPageData> _pageFuture;
  var _checkoutLoading = false;
  var _cancelLoading = false;

  @override
  void initState() {
    super.initState();
    _pageFuture = _loadPage();
  }

  @override
  void dispose() {
    _usersCtrl.dispose();
    super.dispose();
  }

  Future<_SubPageData> _loadPage() async {
    final sub = await _service.currentForCompany(widget.profile.companyId);
    final risk = await _service.fetchCompanyRiskScore(widget.profile.companyId);
    var invoices = <InvoiceHistoryItem>[];
    if (widget.profile.isAdmin) {
      try {
        invoices = await _service.fetchInvoiceHistory();
      } catch (_) {
        invoices = const [];
      }
    }
    return _SubPageData(sub, risk, invoices);
  }

  Future<void> _reload() async {
    setState(() {
      _pageFuture = _loadPage();
    });
  }

  String _planLabel(String plan, AppLocalizations l10n) {
    switch (plan) {
      case 'flex':
        return l10n.subscription_plan_flex;
      case 'starter':
        return l10n.starter;
      case 'pro':
        return l10n.pro;
      case 'business':
        return l10n.business;
      default:
        return plan;
    }
  }

  String _invoiceStatusLabel(AppLocalizations l10n, String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return l10n.subscription_invoice_status_paid;
      case 'open':
        return l10n.subscription_invoice_status_open;
      case 'draft':
        return l10n.subscription_invoice_status_draft;
      case 'void':
        return l10n.subscription_invoice_status_void;
      case 'uncollectible':
        return l10n.subscription_invoice_status_uncollectible;
      default:
        return status;
    }
  }

  String _formatInvoiceAmount(InvoiceHistoryItem item) {
    final major = item.displayAmountCents / 100.0;
    final sym = switch (item.currency.toLowerCase()) {
      'usd' => r'$',
      'eur' => '€',
      _ => '${item.currency.toUpperCase()} ',
    };
    return '$sym${major.toStringAsFixed(2)}';
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _checkout(AppLocalizations l10n) async {
    final parsed = int.tryParse(_usersCtrl.text.trim());
    if (parsed == null || parsed < 1) {
      AppSnack.error(context, l10n.subscription_seats_invalid);
      return;
    }
    setState(() => _checkoutLoading = true);
    try {
      await _service.openCheckout(users: parsed);
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
        setState(() => _checkoutLoading = false);
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

  Future<void> _confirmCancel(AppLocalizations l10n) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.subscription_cancel_confirm_title),
        content: Text(l10n.subscription_cancel_confirm_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.subscription_cancel_confirm_action),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;

    setState(() => _cancelLoading = true);
    try {
      await _service.cancelSubscriptionAtPeriodEnd();
      if (mounted) {
        AppSnack.success(context, l10n.subscription_cancel_scheduled);
      }
      await _reload();
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _cancelLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = NumberFormat.currency(symbol: r'$');
    final dateFmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());

    return FutureBuilder<_SubPageData>(
      future: _pageFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }

        if (snap.hasError || snap.data == null) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                snap.error?.toString() ?? l10n.error_generic,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _reload,
                child: Text(l10n.refresh),
              ),
            ],
          );
        }

        final data = snap.data!;
        final current = data.subscription;
        final riskScore = data.riskScore;
        final invoices = data.invoices;
        final users = int.tryParse(_usersCtrl.text.trim()) ?? 0;
        final estimate = users >= 1
            ? computeMonthlySubscriptionUsd(
                users: users,
                riskScore: riskScore,
              )
            : 0.0;
        final estimateLabel = currency.format(estimate);
        final canCancel = widget.profile.isAdmin &&
            (current?.canRequestStripeCancel ?? false);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.pricing,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.current_plan}: ${_planLabel(current?.plan ?? 'flex', l10n)}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            if (current?.licensedSeats != null) ...[
              const SizedBox(height: 4),
              Text('${l10n.subscription_seats_label}: ${current!.licensedSeats}'),
            ],
            if (current != null) ...[
              const SizedBox(height: 4),
              Text('${l10n.status}: ${current.status}'),
            ],
            if (widget.profile.isAdmin) ...[
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.subscription_purchase_history,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (invoices.isEmpty)
                      Text(
                        l10n.subscription_no_invoices,
                        style: const TextStyle(color: Colors.white60),
                      )
                    else
                      ...invoices.asMap().entries.expand((e) {
                        final i = e.key;
                        final inv = e.value;
                        final when = inv.created > 0
                            ? dateFmt.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  inv.created * 1000,
                                  isUtc: true,
                                ).toLocal(),
                              )
                            : '—';
                        final isLast = i == invoices.length - 1;
                        return [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${l10n.subscription_invoice_ref}: ${inv.number ?? inv.id}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ),
                                    Text(
                                      _formatInvoiceAmount(inv),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.subscription_invoice_on}: $when · ${_invoiceStatusLabel(l10n, inv.status)}',
                                  style: const TextStyle(color: Colors.white60),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (inv.hostedInvoiceUrl != null)
                                      TextButton(
                                        onPressed: () =>
                                            _openUrl(inv.hostedInvoiceUrl),
                                        child: Text(
                                          l10n.subscription_open_invoice,
                                        ),
                                      ),
                                    if (inv.invoicePdf != null)
                                      TextButton(
                                        onPressed: () =>
                                            _openUrl(inv.invoicePdf),
                                        child: Text(
                                          l10n.subscription_download_pdf,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            const Divider(height: 24),
                        ];
                      }),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                l10n.subscription_history_admin_only,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.subscription_plan_flex,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.subscription_pricing_explainer(
                      currency.format(2.99),
                    ),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.subscription_company_risk_value(riskScore),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usersCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.subscription_seats_label,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.subscription_estimated_monthly(estimateLabel),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkoutLoading
                          ? null
                          : () => _checkout(l10n),
                      child: Text(
                        _checkoutLoading
                            ? l10n.loading
                            : l10n.subscription_continue_checkout,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _manage,
                  child: Text(l10n.manage_subscription),
                ),
                if (canCancel)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    onPressed: _cancelLoading
                        ? null
                        : () => _confirmCancel(l10n),
                    child: Text(
                      _cancelLoading
                          ? l10n.loading
                          : l10n.subscription_cancel_subscription,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
