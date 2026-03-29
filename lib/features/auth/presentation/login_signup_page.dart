import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/utils/app_snack.dart';
import '../../subscription/data/subscription_service.dart';
import '../data/auth_service.dart';
import '../models/app_profile.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({required this.authService, super.key});

  final AuthService authService;

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _companyCodeCtrl = TextEditingController();
  final _licensedSeatsCtrl = TextEditingController(text: '10');

  var _isLogin = true;
  var _busy = false;
  var _role = AppUserRole.admin;
  var _startWithTrial = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _companyNameCtrl.dispose();
    _companyCodeCtrl.dispose();
    _licensedSeatsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _busy = true);
    try {
      if (_isLogin) {
        await widget.authService.signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
      } else {
        final response = await widget.authService.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          role: _role,
          onboardingMode: _startWithTrial ? 'trial' : 'paid',
          selectedPlan: 'flex',
          companyName: _role == AppUserRole.admin
              ? _companyNameCtrl.text.trim()
              : null,
          companyCode: _role != AppUserRole.admin
              ? _companyCodeCtrl.text.trim()
              : null,
        );

        final paidAdmin =
            _role == AppUserRole.admin && !_startWithTrial;
        if (paidAdmin && response.session != null) {
          if (!mounted) return;
          final stripeLocale =
              Localizations.localeOf(context).toLanguageTag();
          final seats = int.tryParse(_licensedSeatsCtrl.text.trim()) ?? 1;
          final users = seats.clamp(1, 50000);
          AppSnack.success(context, l10n.sign_up_opening_checkout);
          try {
            await SubscriptionService().openCheckout(
              users: users,
              stripeLocale: stripeLocale,
            );
          } catch (checkoutError) {
            if (mounted) {
              AppSnack.error(context, checkoutError.toString());
            }
          }
        } else if (paidAdmin && response.session == null) {
          if (mounted) {
            AppSnack.success(context, l10n.sign_up_verify_email_then_pay);
          }
        } else if (mounted) {
          AppSnack.success(context, l10n.sign_up_success_check_email);
        }
      }
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
    final l10n = AppLocalizations.of(context);

    return Material(
      child: SizedBox.expand(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                    Color(0xFF022C22),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.app_title,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.security_posture,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 24),
                              if (!_isLogin) ...[
                                TextFormField(
                                  controller: _nameCtrl,
                                  decoration: InputDecoration(
                                    labelText: l10n.name,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? l10n.error_generic
                                      : null,
                                ),
                                const SizedBox(height: 12),
                              ],
                              TextFormField(
                                controller: _emailCtrl,
                                decoration: InputDecoration(
                                  labelText: l10n.email,
                                ),
                                validator: (v) =>
                                    (v == null || !v.contains('@'))
                                    ? l10n.error_generic
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.password,
                                ),
                                validator: (v) => (v == null || v.length < 8)
                                    ? l10n.error_generic
                                    : null,
                              ),
                              if (!_isLogin) ...[
                                const SizedBox(height: 12),
                                DropdownButtonFormField<AppUserRole>(
                                  initialValue: _role,
                                  decoration: InputDecoration(
                                    labelText: l10n.role,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: AppUserRole.admin,
                                      child: Text(l10n.admin),
                                    ),
                                    DropdownMenuItem(
                                      value: AppUserRole.securityManager,
                                      child: Text(l10n.role_security_manager),
                                    ),
                                    DropdownMenuItem(
                                      value: AppUserRole.employee,
                                      child: Text(l10n.employee),
                                    ),
                                    DropdownMenuItem(
                                      value: AppUserRole.auditor,
                                      child: Text(l10n.role_auditor),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() => _role = value);
                                  },
                                ),
                                const SizedBox(height: 12),
                                if (_role == AppUserRole.admin)
                                  TextFormField(
                                    controller: _companyNameCtrl,
                                    decoration: InputDecoration(
                                      labelText: l10n.company_name,
                                    ),
                                    validator: (v) {
                                      if (_role == AppUserRole.admin &&
                                          (v == null || v.trim().isEmpty)) {
                                        return l10n.error_generic;
                                      }
                                      return null;
                                    },
                                  ),
                                if (_role == AppUserRole.admin) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.subscription_activation,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  SegmentedButton<bool>(
                                    segments: [
                                      ButtonSegment<bool>(
                                        value: true,
                                        label: Text(l10n.trial_30_days),
                                      ),
                                      ButtonSegment<bool>(
                                        value: false,
                                        label: Text(l10n.stripe_monthly_now),
                                      ),
                                    ],
                                    selected: {_startWithTrial},
                                    onSelectionChanged: (selection) {
                                      setState(
                                        () => _startWithTrial = selection.first,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _startWithTrial
                                        ? l10n.trial_then_paywall
                                        : l10n.stripe_pay_immediately,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  if (!_startWithTrial) ...[
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _licensedSeatsCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        labelText:
                                            l10n.signup_licensed_seats_label,
                                        hintText:
                                            l10n.signup_licensed_seats_hint,
                                      ),
                                      validator: (v) {
                                        final raw = v?.trim() ?? '';
                                        final n = int.tryParse(raw);
                                        if (n == null ||
                                            n < 1 ||
                                            n > 50000) {
                                          return l10n.error_generic;
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ],
                                if (_role != AppUserRole.admin)
                                  TextFormField(
                                    controller: _companyCodeCtrl,
                                    decoration: InputDecoration(
                                      labelText: l10n.company_code,
                                    ),
                                    validator: (v) {
                                      if (_role != AppUserRole.admin &&
                                          (v == null || v.trim().isEmpty)) {
                                        return l10n.error_generic;
                                      }
                                      return null;
                                    },
                                  ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _busy ? null : _submit,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      _isLogin
                                          ? l10n.sign_in
                                          : l10n.create_account,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () {
                                          setState(() => _isLogin = !_isLogin);
                                        },
                                  child: Text(
                                    _isLogin
                                        ? '${l10n.dont_have_account} ${l10n.signup}'
                                        : '${l10n.already_have_account} ${l10n.login}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
