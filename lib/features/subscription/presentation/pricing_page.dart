import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sass_security/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/platform/app_platform.dart';
import '../../../core/pricing/subscription_price.dart';
import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/models/app_profile.dart';
import '../data/store_iap_service.dart';
import '../data/subscription_service.dart';
import '../models/billing_history_event.dart';
import '../models/invoice_history_item.dart';
import '../models/subscription_record.dart';

class _SubPageData {
  _SubPageData(this.subscription, this.riskScore, this.invoices, this.billingEvents);

  final SubscriptionRecord? subscription;
  final int riskScore;
  final List<InvoiceHistoryItem> invoices;
  final List<BillingHistoryEvent> billingEvents;
}

class PricingPage extends StatefulWidget {
  const PricingPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final _service = SubscriptionService();
  final _storeIap = StoreIapService();
  final _usersCtrl = TextEditingController(text: '5');
  late Future<_SubPageData> _pageFuture;
  var _checkoutLoading = false;
  var _cancelLoading = false;
  var _checkoutYearly = false;
  var _scheduleMonthlyLoading = false;
  var _storeAvailable = false;
  var _storeProductsOk = false;
  var _storeBuying = false;

  @override
  void initState() {
    super.initState();
    _pageFuture = _loadPage();
    if (isMobileNativeApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initStoreBilling());
    }
  }

  @override
  void dispose() {
    if (isMobileNativeApp) {
      unawaited(_storeIap.detachListener());
    }
    _usersCtrl.dispose();
    super.dispose();
  }

  Future<void> _initStoreBilling() async {
    if (!isMobileNativeApp || !widget.profile.isAdmin) return;
    _storeIap.attachListener((err) async {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      if (err != null && err.isNotEmpty) {
        AppSnack.error(context, err);
      } else {
        AppSnack.success(context, loc.subscription_store_success);
        await _reload();
      }
    });
    final av = await _storeIap.isAvailable;
    if (!mounted) return;
    final ids = await _storeIap.queryStoreProductIds(_checkoutYearly);
    if (!mounted) return;
    setState(() {
      _storeAvailable = av;
      _storeProductsOk = ids.isNotEmpty;
    });
    await _storeIap.restore();
  }

  Future<void> _buyStore(AppLocalizations l10n) async {
    setState(() => _storeBuying = true);
    try {
      final ok = await _storeIap.buySubscription(_checkoutYearly);
      if (!ok && mounted) {
        AppSnack.error(context, l10n.subscription_store_unavailable);
      }
    } finally {
      if (mounted) {
        setState(() => _storeBuying = false);
      }
    }
  }

  String _intervalOrStoreLabel(SubscriptionRecord c, AppLocalizations l10n) {
    if (c.isNativeStoreBilling) {
      return c.billingProvider == 'app_store'
          ? l10n.subscription_billing_provider_appstore
          : l10n.subscription_billing_provider_play;
    }
    return c.billingInterval == 'year'
        ? l10n.subscription_billing_yearly
        : l10n.subscription_billing_monthly;
  }

  Future<_SubPageData> _loadPage() async {
    final sub = await _service.currentForCompany(widget.profile.companyId);
    if (sub?.licensedSeats != null && mounted) {
      _usersCtrl.text = '${sub!.licensedSeats}';
    }
    final risk = await _service.fetchCompanyRiskScore(widget.profile.companyId);
    var invoices = <InvoiceHistoryItem>[];
    var billingEvents = <BillingHistoryEvent>[];
    if (widget.profile.isAdmin) {
      try {
        final snap = await _service.fetchBillingSnapshot();
        invoices = snap.invoices;
        billingEvents = snap.billingEvents;
      } catch (_) {
        invoices = const [];
        billingEvents = const [];
      }
    }
    return _SubPageData(sub, risk, invoices, billingEvents);
  }

  Future<void> _reload() async {
    setState(() {
      _pageFuture = _loadPage();
    });
  }

  String _billingEventTitle(
    BillingHistoryEvent ev,
    AppLocalizations l10n,
    DateFormat dateFmt,
  ) {
    switch (ev.eventType) {
      case 'switch_to_monthly_scheduled':
        final d = ev.effectiveAtIso != null
            ? dateFmt.format(DateTime.parse(ev.effectiveAtIso!).toLocal())
            : dateFmt.format(ev.createdAt.toLocal());
        return l10n.subscription_event_switch_monthly(d);
      default:
        return ev.eventType;
    }
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
      await _service.openCheckout(
        users: parsed,
        stripeLocale: Localizations.localeOf(context).toLanguageTag(),
        billingInterval: _checkoutYearly ? 'year' : 'month',
      );
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
      final sub = await _service.currentForCompany(widget.profile.companyId);
      if (sub?.isNativeStoreBilling ?? false) {
        if (mounted) {
          AppSnack.success(context, l10n.subscription_manage_in_store);
        }
        return;
      }
      if (!mounted) return;
      await _service.openBillingPortal(
        stripeLocale: Localizations.localeOf(context).toLanguageTag(),
      );
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

  Future<void> _confirmScheduleMonthly(AppLocalizations l10n) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.subscription_switch_to_monthly_confirm_title),
        content: Text(l10n.subscription_switch_to_monthly_confirm_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.subscription_switch_to_monthly_confirm_action),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;

    setState(() => _scheduleMonthlyLoading = true);
    try {
      await _service.scheduleMonthlyAtRenewal();
      if (mounted) {
        AppSnack.success(context, l10n.subscription_switch_to_monthly_scheduled);
      }
      await _reload();
    } catch (error) {
      if (mounted) {
        if (error is SubscriptionBillingException && error.message == 'already_monthly') {
          AppSnack.error(context, l10n.subscription_already_monthly);
        } else {
          AppSnack.error(context, error.toString());
        }
      }
    } finally {
      if (mounted) {
        setState(() => _scheduleMonthlyLoading = false);
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
        final billingEvents = data.billingEvents;
        final users = int.tryParse(_usersCtrl.text.trim()) ?? 0;
        final monthlyEstimate = users >= 1
            ? computeMonthlySubscriptionUsd(
                users: users,
                riskScore: riskScore,
              )
            : 0.0;
        final displayEstimate =
            _checkoutYearly ? monthlyEstimate * 12 : monthlyEstimate;
        final estimateLabel = currency.format(displayEstimate);
        final estimateText = _checkoutYearly
            ? l10n.subscription_estimated_yearly(estimateLabel)
            : l10n.subscription_estimated_monthly(estimateLabel);
        final canCancel = widget.profile.isAdmin &&
            (current?.canRequestStripeCancel ?? false);
        final canScheduleMonthly = widget.profile.isAdmin &&
            (current?.canScheduleMonthlyAtRenewal ?? false);

        final bottomPad = MediaQuery.paddingOf(context).bottom;
        return ListView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomPad),
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
            if (current != null &&
                ((current.stripeSubscriptionId ?? '').isNotEmpty ||
                    current.isNativeStoreBilling)) ...[
              const SizedBox(height: 4),
              Text(
                l10n.subscription_billing_current(
                  _intervalOrStoreLabel(current, l10n),
                ),
              ),
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
                    const SizedBox(height: 16),
                    Text(
                      l10n.subscription_billing_activity,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (billingEvents.isEmpty)
                      Text(
                        l10n.subscription_no_billing_events,
                        style: const TextStyle(color: Colors.white60),
                      )
                    else
                      ...billingEvents.asMap().entries.expand((e) {
                        final i = e.key;
                        final ev = e.value;
                        final recorded = dateFmt.format(ev.createdAt.toLocal());
                        final isLastEv = i == billingEvents.length - 1;
                        return [
                          Text(
                            _billingEventTitle(ev, l10n, dateFmt),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            recorded,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          if (!isLastEv || invoices.isNotEmpty)
                            const Divider(height: 20),
                        ];
                      }),
                    if (billingEvents.isNotEmpty || invoices.isNotEmpty)
                      const SizedBox(height: 8),
                    Text(
                      l10n.subscription_section_invoices,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
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
                    l10n.subscription_billing_checkout_cadence,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text(l10n.subscription_billing_monthly),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text(l10n.subscription_billing_yearly),
                      ),
                    ],
                    selected: {_checkoutYearly},
                    onSelectionChanged: (next) async {
                      final y = next.first;
                      setState(() => _checkoutYearly = y);
                      if (isMobileNativeApp) {
                        final ids = await _storeIap.queryStoreProductIds(y);
                        if (mounted) {
                          setState(() => _storeProductsOk = ids.isNotEmpty);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    estimateText,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (isMobileNativeApp && widget.profile.isAdmin) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.subscription_store_disclaimer,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                    if (_storeAvailable && _storeProductsOk) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _storeBuying ? null : () => _buyStore(l10n),
                          child: Text(
                            _storeBuying
                                ? l10n.loading
                                : l10n.subscription_pay_with_store,
                          ),
                        ),
                      ),
                    ] else if (_storeAvailable) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.subscription_store_unavailable,
                        style: const TextStyle(color: Colors.orangeAccent),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      l10n.subscription_pay_with_card_browser,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
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
                            : isMobileNativeApp
                                ? l10n.subscription_pay_with_card_browser
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
                if (canScheduleMonthly)
                  OutlinedButton(
                    onPressed: _scheduleMonthlyLoading
                        ? null
                        : () => _confirmScheduleMonthly(l10n),
                    child: Text(
                      _scheduleMonthlyLoading
                          ? l10n.loading
                          : l10n.subscription_switch_to_monthly,
                    ),
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
