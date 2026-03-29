import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/employee_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../auth/models/app_profile.dart';
import '../data/employee_avatar_storage.dart';
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
  final _avatarStorage = EmployeeAvatarStorage();
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
    final passwordCtrl = TextEditingController(
      text: '${existing?.passwordBehaviorScore ?? 30}',
    );
    final incidentCtrl = TextEditingController(
      text: '${existing?.incidentHistoryScore ?? 0}',
    );
    final deviceCtrl = TextEditingController(
      text: '${existing?.deviceComplianceScore ?? 25}',
    );
    final behaviorCtrl = TextEditingController(
      text: '${existing?.behaviorRiskScore ?? 15}',
    );
    var role = existing?.role ?? AppUserRole.employee;
    var mfaEnabled = existing?.mfaEnabled ?? false;
    var forceMfa = existing?.forceMfa ?? false;

    String? avatarUrl = existing?.avatarUrl;
    Uint8List? pendingBytes;
    String pendingExt = 'jpg';
    var clearedAvatar = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickPhoto() async {
              final picker = ImagePicker();
              final file = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1200,
                maxHeight: 1200,
                imageQuality: 88,
              );
              if (file == null) return;
              final bytes = await file.readAsBytes();
              if (bytes.length > EmployeeAvatarStorage.maxBytes) {
                if (dialogContext.mounted) {
                  AppSnack.error(dialogContext, l10n.photo_invalid);
                }
                return;
              }
              final name = file.name;
              final dot = name.lastIndexOf('.');
              if (dot >= 0 && dot < name.length - 1) {
                pendingExt = name.substring(dot + 1).toLowerCase();
                if (pendingExt == 'jpeg') pendingExt = 'jpg';
              }
              pendingBytes = bytes;
              clearedAvatar = false;
              setDialogState(() {});
            }

            void clearPhoto() {
              pendingBytes = null;
              avatarUrl = null;
              clearedAvatar = true;
              setDialogState(() {});
            }

            return AlertDialog(
              title: Text(
                existing == null ? l10n.add_employee : l10n.edit_employee,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.profile.isManager) ...[
                      Text(
                        l10n.employee_photo,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (pendingBytes != null)
                            ClipOval(
                              child: Image.memory(
                                pendingBytes!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            EmployeeAvatar(
                              name: nameCtrl.text.isEmpty
                                  ? '?'
                                  : nameCtrl.text,
                              imageUrl: avatarUrl,
                              radius: 32,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                TextButton.icon(
                                  onPressed: pickPhoto,
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: Text(l10n.change_photo),
                                ),
                                if (pendingBytes != null ||
                                    (avatarUrl != null &&
                                        avatarUrl!.isNotEmpty))
                                  TextButton.icon(
                                    onPressed: clearPhoto,
                                    icon: const Icon(Icons.delete_outline),
                                    label: Text(l10n.remove_photo),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(labelText: l10n.name),
                      onChanged: (_) => setDialogState(() {}),
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
                        if (value == null) return;
                        setDialogState(() => role = value);
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
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.password_behavior_risk,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: incidentCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.incident_history_risk,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: deviceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.device_compliance_risk,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: behaviorCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.behavior_risk,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: mfaEnabled,
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.mfa_enabled_label),
                      onChanged: (value) {
                        setDialogState(() => mfaEnabled = value);
                      },
                    ),
                    SwitchListTile(
                      value: forceMfa,
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.force_mfa_login),
                      onChanged: (value) {
                        setDialogState(() => forceMfa = value);
                      },
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
      },
    );

    if (result != true) {
      return;
    }

    try {
      final parsedRisk = int.tryParse(riskCtrl.text.trim()) ?? 0;
      final parsedTraining = int.tryParse(trainingCtrl.text.trim()) ?? 0;
      final parsedPassword = int.tryParse(passwordCtrl.text.trim()) ?? 30;
      final parsedIncident = int.tryParse(incidentCtrl.text.trim()) ?? 0;
      final parsedDevice = int.tryParse(deviceCtrl.text.trim()) ?? 25;
      final parsedBehavior = int.tryParse(behaviorCtrl.text.trim()) ?? 15;

      late final String employeeId;
      if (existing == null) {
        employeeId = await _repo.create(
          companyId: widget.profile.companyId,
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          role: role,
          riskScore: parsedRisk,
          trainingCompletion: parsedTraining,
          passwordBehaviorScore: parsedPassword,
          incidentHistoryScore: parsedIncident,
          deviceComplianceScore: parsedDevice,
          behaviorRiskScore: parsedBehavior,
          mfaEnabled: mfaEnabled,
          forceMfa: forceMfa,
        );
      } else {
        employeeId = existing.id;
        final String? avatarForRow;
        if (clearedAvatar && pendingBytes == null) {
          avatarForRow = null;
        } else if (pendingBytes != null) {
          avatarForRow = existing.avatarUrl;
        } else {
          avatarForRow = existing.avatarUrl;
        }
        await _repo.update(
          employeeId: existing.id,
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          role: role,
          riskScore: parsedRisk,
          trainingCompletion: parsedTraining,
          passwordBehaviorScore: parsedPassword,
          incidentHistoryScore: parsedIncident,
          deviceComplianceScore: parsedDevice,
          behaviorRiskScore: parsedBehavior,
          mfaEnabled: mfaEnabled,
          forceMfa: forceMfa,
          avatarUrl: avatarForRow,
        );
      }

      if (pendingBytes != null) {
        try {
          final url = await _avatarStorage.upload(
            companyId: widget.profile.companyId,
            employeeId: employeeId,
            bytes: pendingBytes!,
            ext: pendingExt,
          );
          await _repo.updateAvatarUrl(employeeId, url);
        } catch (_) {
          if (mounted) {
            AppSnack.error(context, l10n.photo_upload_failed);
          }
        }
      } else if (clearedAvatar &&
          existing != null &&
          (existing.avatarUrl != null && existing.avatarUrl!.isNotEmpty)) {
        await _avatarStorage.removeFilesForEmployee(
          widget.profile.companyId,
          employeeId,
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
      await _avatarStorage.removeFilesForEmployee(
        widget.profile.companyId,
        id,
      );
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
            action: widget.profile.isManager
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
            itemCount: employees.length + (widget.profile.isManager ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (widget.profile.isManager && index == 0) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () => _createOrEdit(),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.add_employee),
                  ),
                );
              }

              final employeeIndex = widget.profile.isManager
                  ? index - 1
                  : index;
              final employee = employees[employeeIndex];
              return GlassCard(
                child: Row(
                  children: [
                    EmployeeAvatar(
                      name: employee.name,
                      imageUrl: employee.avatarUrl,
                      radius: 26,
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
                            '${l10n.risk_score}: ${employee.riskScore} | ${l10n.training_completion}: ${employee.trainingCompletion}% | ${l10n.mfa_enabled_label}: ${employee.mfaEnabled ? l10n.mfa_on : l10n.mfa_off}',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    if (widget.profile.isManager)
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
