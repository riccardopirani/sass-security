import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/localization/locale_controller.dart';
import '../../alerts/presentation/alerts_page.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/models/app_profile.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../employees/presentation/employees_page.dart';
import '../../phishing/presentation/phishing_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../subscription/presentation/pricing_page.dart';

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
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _items(l10n);

    if (_selected >= items.length) {
      _selected = 0;
    }

    final selectedItem = items[_selected];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        return Scaffold(
          appBar: AppBar(
            title: Text(selectedItem.label),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          bottomNavigationBar: wide
              ? null
              : BottomNavigationBar(
                  currentIndex: _selected,
                  onTap: (index) => setState(() => _selected = index),
                  type: BottomNavigationBarType.fixed,
                  items: items
                      .map(
                        (item) => BottomNavigationBarItem(
                          icon: Icon(item.icon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF020617),
                  Color(0xFF0B1324),
                  Color(0xFF052E2B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              top: false,
              child: wide
                  ? Row(
                      children: [
                        NavigationRail(
                          selectedIndex: _selected,
                          minWidth: 92,
                          labelType: NavigationRailLabelType.all,
                          onDestinationSelected: (index) {
                            setState(() => _selected = index);
                          },
                          destinations: items
                              .map(
                                (item) => NavigationRailDestination(
                                  icon: Icon(item.icon),
                                  label: Text(item.label),
                                ),
                              )
                              .toList(),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: KeyedSubtree(
                              key: ValueKey(selectedItem.label),
                              child: selectedItem.page,
                            ),
                          ),
                        ),
                      ],
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: KeyedSubtree(
                        key: ValueKey(selectedItem.label),
                        child: selectedItem.page,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  List<_ShellItem> _items(AppLocalizations l10n) {
    return [
      _ShellItem(
        label: l10n.dashboard,
        icon: Icons.space_dashboard_outlined,
        page: DashboardPage(profile: widget.profile),
      ),
      _ShellItem(
        label: l10n.employees,
        icon: Icons.groups_2_outlined,
        page: EmployeesPage(profile: widget.profile),
      ),
      _ShellItem(
        label: l10n.alerts,
        icon: Icons.notification_important_outlined,
        page: AlertsPage(profile: widget.profile),
      ),
      if (widget.profile.isAdmin)
        _ShellItem(
          label: l10n.phishing,
          icon: Icons.email_outlined,
          page: PhishingPage(profile: widget.profile),
        ),
      _ShellItem(
        label: l10n.subscription,
        icon: Icons.credit_card_outlined,
        page: PricingPage(profile: widget.profile),
      ),
      _ShellItem(
        label: l10n.settings,
        icon: Icons.settings_outlined,
        page: SettingsPage(
          profile: widget.profile,
          localeController: widget.localeController,
          authService: widget.authService,
        ),
      ),
    ];
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
