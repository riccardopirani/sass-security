import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../auth/models/app_profile.dart';
import '../data/employee_repository.dart';
import '../models/employee_record.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final _repo = EmployeeRepository();
  late Future<List<EmployeeRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.listByCompany(widget.profile.companyId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.listByCompany(widget.profile.companyId);
    });
  }

  Future<void> _createOrEdit({EmployeeRecord? existing}) async {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final riskCtrl = TextEditingController(text: '${existing?.riskScore ?? 0}');
    final trainingCtrl = TextEditingController(
      text: '${existing?.trainingCompletion ?? 0}',
    );
    var role = existing?.role ?? AppUserRole.employee;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existing == null ? l10n.add_employee : l10n.edit_employee,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l10n.name),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(labelText: l10n.email),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AppUserRole>(
                  initialValue: role,
                  decoration: InputDecoration(labelText: l10n.role),
                  items: [
                    DropdownMenuItem(
                      value: AppUserRole.admin,
                      child: Text(l10n.admin),
                    ),
                    DropdownMenuItem(
                      value: AppUserRole.employee,
                      child: Text(l10n.employee),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    role = value;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: riskCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.risk_score),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: trainingCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.training_completion,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    try {
      final parsedRisk = int.tryParse(riskCtrl.text.trim()) ?? 0;
      final parsedTraining = int.tryParse(trainingCtrl.text.trim()) ?? 0;

      if (existing == null) {
        await _repo.create(
          companyId: widget.profile.companyId,
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          role: role,
          riskScore: parsedRisk,
          trainingCompletion: parsedTraining,
        );
      } else {
        await _repo.update(
          employeeId: existing.id,
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          role: role,
          riskScore: parsedRisk,
          trainingCompletion: parsedTraining,
        );
      }

      if (mounted) {
        AppSnack.success(context, l10n.success);
      }
      await _reload();
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    }
  }

  Future<void> _delete(String id) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _repo.delete(id);
      if (mounted) {
        AppSnack.success(context, l10n.success);
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

    return FutureBuilder<List<EmployeeRecord>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingSkeleton(height: 88),
              SizedBox(height: 10),
              LoadingSkeleton(height: 88),
              SizedBox(height: 10),
              LoadingSkeleton(height: 88),
            ],
          );
        }

        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(snapshot.error.toString()),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _reload, child: Text(l10n.refresh)),
            ],
          );
        }

        final employees = snapshot.data ?? const <EmployeeRecord>[];
        if (employees.isEmpty) {
          return EmptyState(
            title: l10n.no_employees,
            icon: Icons.groups_2_outlined,
            action: widget.profile.isAdmin
                ? ElevatedButton(
                    onPressed: () => _createOrEdit(),
                    child: Text(l10n.add_employee),
                  )
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: employees.length + (widget.profile.isAdmin ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (widget.profile.isAdmin && index == 0) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () => _createOrEdit(),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.add_employee),
                  ),
                );
              }

              final employeeIndex = widget.profile.isAdmin ? index - 1 : index;
              final employee = employees[employeeIndex];
              return GlassCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0EA5E9),
                      child: Text(
                        employee.name.isEmpty ? '?' : employee.name[0],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            employee.email,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.risk_score}: ${employee.riskScore} | ${l10n.training_completion}: ${employee.trainingCompletion}%',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    if (widget.profile.isAdmin)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _createOrEdit(existing: employee);
                          } else if (value == 'delete') {
                            _delete(employee.id);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(l10n.edit_employee),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l10n.delete_employee),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant EmployeesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.companyId != widget.profile.companyId) {
      _reload();
    }
  }
}
