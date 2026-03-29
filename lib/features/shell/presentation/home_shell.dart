import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/shell_content.dart';
import '../../alerts/presentation/alerts_page.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/models/app_profile.dart';
import '../../companion/presentation/companion_page.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../employees/presentation/employees_page.dart';
import '../../news/presentation/news_page.dart';
import '../../operations/presentation/operations_page.dart';
import '../../phishing/presentation/phishing_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../subscription/data/subscription_service.dart';
import '../../subscription/presentation/pricing_page.dart';

/// Layout breakpoints for navigation (drawer vs rail).
const double kAppShellRailBreakpoint = 960;
const double kAppShellRailExtendedBreakpoint = 1280;

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.profile,
    required this.localeController,
    required this.authService,
    super.key,
  });

  final AppProfile profile;
  final LocaleController localeController;
  final AuthService authService;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _selected = 0;
  final _subscriptionService = SubscriptionService();
  var _subscriptionGateChecked = false;

  static const _bodyGradient = LinearGradient(
    colors: [
      Color(0xFF020617),
      Color(0xFF0B1324),
      Color(0xFF052E2B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscriptionGateChecked) return;
    _subscriptionGateChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enforceSubscriptionGate();
    });
  }

  Future<void> _enforceSubscriptionGate() async {
    if (!mounted || !widget.profile.isAdmin) return;
    try {
      final l10n = AppLocalizations.of(context);
      final subscription = await _subscriptionService.currentForCompany(
        widget.profile.companyId,
      );
      if (!mounted) return;

      final now = DateTime.now();
      final status = subscription?.status.toLowerCase() ?? 'inactive';
      final trialValid =
          status == 'trialing' &&
          subscription?.currentPeriodEnd != null &&
          subscription!.currentPeriodEnd!.isAfter(now);
      final hasAccess = status == 'active' || trialValid;
      if (hasAccess) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Abbonamento richiesto'),
            content: const Text(
              'Il periodo gratuito e terminato oppure non e attivo alcun piano. '
              'Completa il pagamento su Stripe per continuare a usare la piattaforma.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  final items = _items(l10n);
                  final pricingIndex = items.indexWhere(
                    (item) => item.label == l10n.subscription,
                  );
                  if (pricingIndex >= 0) {
                    setState(() => _selected = pricingIndex);
                  }
                },
                child: const Text('Vai ai piani'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await widget.authService.signOut();
                },
                child: const Text('Esci'),
              ),
            ],
          );
        },
      );
    } catch (_) {
      // If subscription check fails, do not block navigation.
    }
  }

  void _selectNav(int index, {bool closeDrawer = false}) {
    setState(() => _selected = index);
    if (closeDrawer && _scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _items(l10n);

    if (_selected >= items.length) {
      _selected = 0;
    }

    final selectedItem = items[_selected];
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final useRail = width >= kAppShellRailBreakpoint;
        final railExtended = width >= kAppShellRailExtendedBreakpoint;

        return Scaffold(
          key: _scaffoldKey,
          drawer: useRail ? null : _buildNavigationDrawer(items, l10n),
          appBar: _ShellAppBar(
            useRail: useRail,
            title: selectedItem.label,
            subtitle: widget.profile.companyName,
            onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            theme: theme,
            localeController: widget.localeController,
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(gradient: _bodyGradient),
            child: SafeArea(
              top: false,
              child: useRail
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SideRail(
                          items: items,
                          selectedIndex: _selected,
                          extended: railExtended,
                          profile: widget.profile,
                          onSelect: (i) => _selectNav(i),
                        ),
                        Expanded(
                          child: _ContentPane(
                            pageKey: selectedItem.label,
                            child: selectedItem.page,
                          ),
                        ),
                      ],
                    )
                  : _ContentPane(
                      pageKey: selectedItem.label,
                      child: selectedItem.page,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationDrawer(
    List<_ShellItem> items,
    AppLocalizations l10n,
  ) {
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.88).clamp(280.0, 340.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(profile: widget.profile),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = index == _selected;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: selected
                          ? const Color(0xFF14B8A6).withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _selectNav(index, closeDrawer: true),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: selected
                                    ? const Color(0xFF14B8A6)
                                    : Colors.white70,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: selected
                                            ? Colors.white
                                            : Colors.white70,
                                      ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF14B8A6),
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0xFF334155)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Text(
                l10n.settings,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ShellItem> _items(AppLocalizations l10n) {
    return [
      _ShellItem(
        label: l10n.dashboard,
        icon: Icons.space_dashboard_rounded,
        page: DashboardPage(profile: widget.profile),
      ),
      _ShellItem(
        label: l10n.employees,
        icon: Icons.groups_2_rounded,
        page: EmployeesPage(profile: widget.profile),
      ),
      _ShellItem(
        label: 'Alerts',
        icon: Icons.notifications_active_rounded,
        page: AlertsPage(profile: widget.profile),
      ),
      _ShellItem(
        label: 'News',
        icon: Icons.newspaper_rounded,
        page: NewsPage(profile: widget.profile),
      ),
      _ShellItem(
        label: 'Companion',
        icon: Icons.smartphone_rounded,
        page: CompanionPage(profile: widget.profile),
      ),
      if (widget.profile.isManager)
        _ShellItem(
          label: l10n.phishing,
          icon: Icons.mail_lock_rounded,
          page: PhishingPage(profile: widget.profile),
        ),
      if (widget.profile.isManager || widget.profile.isAuditor)
        _ShellItem(
          label: 'Security Ops',
          icon: Icons.psychology_alt_rounded,
          page: OperationsPage(profile: widget.profile),
        ),
      _ShellItem(
        label: l10n.subscription,
        icon: Icons.credit_score_rounded,
        page: PricingPage(profile: widget.profile),
      ),
      _ShellItem(
        label: l10n.settings,
        icon: Icons.settings_rounded,
        page: SettingsPage(
          profile: widget.profile,
          localeController: widget.localeController,
          authService: widget.authService,
        ),
      ),
    ];
  }
}

String _localeMenuLabel(Locale locale) {
  switch (locale.languageCode) {
    case 'it':
      return 'Italiano';
    case 'de':
      return 'Deutsch';
    case 'fr':
      return 'Français';
    case 'zh':
      return '简体中文';
    case 'ru':
      return 'Русский';
    case 'en':
    default:
      return 'English';
  }
}

class _ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ShellAppBar({
    required this.useRail,
    required this.title,
    required this.subtitle,
    required this.onMenu,
    required this.theme,
    required this.localeController,
  });

  final bool useRail;
  final String title;
  final String? subtitle;
  final VoidCallback onMenu;
  final ThemeData theme;
  final LocaleController localeController;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          toolbarHeight: 64,
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: const Color(0x72030712),
          surfaceTintColor: Colors.transparent,
          leading: useRail
              ? const SizedBox(width: 12)
              : IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 26),
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  onPressed: onMenu,
                ),
          title: Column(
            crossAxisAlignment:
                useRail ? CrossAxisAlignment.start : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
            ],
          ),
          actions: [
            ListenableBuilder(
              listenable: localeController,
              builder: (context, _) {
                final l10n = AppLocalizations.of(context);
                return PopupMenuButton<Locale>(
                  tooltip: l10n.choose_language,
                  position: PopupMenuPosition.under,
                  icon: const Icon(Icons.translate_rounded),
                  onSelected: (loc) => localeController.setLocale(loc),
                  itemBuilder: (context) => [
                    for (final loc in LocaleController.supportedLocales)
                      CheckedPopupMenuItem<Locale>(
                        value: loc,
                        checked: loc.languageCode ==
                            localeController.locale.languageCode,
                        child: Text(_localeMenuLabel(loc)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.profile});

  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shield_moon_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'CyberGuard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.companyName ?? profile.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.items,
    required this.selectedIndex,
    required this.extended,
    required this.profile,
    required this.onSelect,
  });

  final List<_ShellItem> items;
  final int selectedIndex;
  final bool extended;
  final AppProfile profile;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF20B1220),
      child: Container(
        width: extended ? 248 : 88,
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Color(0xFF1E293B)),
          ),
        ),
        child: NavigationRail(
          extended: extended,
          backgroundColor: Colors.transparent,
          selectedIndex: selectedIndex,
          minWidth: 80,
          minExtendedWidth: 232,
          groupAlignment: -1,
          onDestinationSelected: onSelect,
          leading: Padding(
            padding: EdgeInsets.fromLTRB(extended ? 12 : 8, 20, extended ? 12 : 8, 12),
            child: extended ? _RailBrandHeader() : const _RailLogoCompact(),
          ),
          destinations: [
            for (var i = 0; i < items.length; i++)
              NavigationRailDestination(
                icon: Icon(items[i].icon),
                selectedIcon: Icon(
                  items[i].icon,
                  color: const Color(0xFF14B8A6),
                ),
                label: Text(items[i].label),
              ),
          ],
          trailing: extended
              ? _RailUserCard(profile: profile)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Tooltip(
                    message: profile.name,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.25),
                      child: Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFF14B8A6),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _RailLogoCompact extends StatelessWidget {
  const _RailLogoCompact();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0EA5E9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.shield_rounded, color: Color(0xFF0F172A), size: 24),
    );
  }
}

class _RailBrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _RailLogoCompact(),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'CyberGuard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
          ),
        ),
      ],
    );
  }
}

class _RailUserCard extends StatelessWidget {
  const _RailUserCard({required this.profile});

  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.22),
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF14B8A6),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentPane extends StatelessWidget {
  const _ContentPane({
    required this.pageKey,
    required this.child,
  });

  final String pageKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>(pageKey),
        child: ShellContent(child: child),
      ),
    );
  }
}

class _ShellItem {
  const _ShellItem({
    required this.label,
    required this.icon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final Widget page;
}
