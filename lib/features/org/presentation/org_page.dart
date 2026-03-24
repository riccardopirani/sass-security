import 'package:flutter/material.dart';

import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/models/app_profile.dart';
import '../data/org_service.dart';

class OrgPage extends StatefulWidget {
  const OrgPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<OrgPage> createState() => _OrgPageState();
}

class _OrgPageState extends State<OrgPage> {
  final _service = OrgService();
  final _departmentCtrl = TextEditingController();
  final _teamCtrl = TextEditingController();

  List<Map<String, dynamic>> _departments = const [];
  List<Map<String, dynamic>> _teams = const [];
  String? _selectedDepartmentId;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _departmentCtrl.dispose();
    _teamCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final departments = await _service.listDepartments(widget.profile.companyId);
      final teams = await _service.listTeams(widget.profile.companyId);
      if (mounted) {
        setState(() {
          _departments = departments;
          _teams = teams;
        });
      }
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addDepartment() async {
    if (_departmentCtrl.text.trim().isEmpty) {
      return;
    }
    try {
      await _service.createDepartment(
        companyId: widget.profile.companyId,
        name: _departmentCtrl.text.trim(),
      );
      _departmentCtrl.clear();
      await _load();
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    }
  }

  Future<void> _addTeam() async {
    if (_teamCtrl.text.trim().isEmpty) {
      return;
    }
    try {
      await _service.createTeam(
        companyId: widget.profile.companyId,
        name: _teamCtrl.text.trim(),
        departmentId: _selectedDepartmentId,
      );
      _teamCtrl.clear();
      await _load();
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.profile.isManager) {
      return const EmptyState(
        title: 'Teams & Departments',
        subtitle: 'Admin/Security Manager access required.',
        icon: Icons.lock_outline,
      );
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Departments',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _departmentCtrl,
                decoration: const InputDecoration(
                  labelText: 'New department name',
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _addDepartment,
                  child: const Text('Add department'),
                ),
              ),
              const SizedBox(height: 8),
              ..._departments.map(
                (dept) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text((dept['name'] as String?) ?? 'Unnamed'),
                ),
              ),
              if (_departments.isEmpty)
                const Text('No departments yet.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teams',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDepartmentId,
                decoration: const InputDecoration(
                  labelText: 'Department (optional)',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No department'),
                  ),
                  ..._departments.map(
                    (dept) => DropdownMenuItem(
                      value: dept['id'] as String?,
                      child: Text((dept['name'] as String?) ?? 'Unnamed'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedDepartmentId = value);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _teamCtrl,
                decoration: const InputDecoration(labelText: 'New team name'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _addTeam,
                  child: const Text('Add team'),
                ),
              ),
              const SizedBox(height: 8),
              ..._teams.map(
                (team) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text((team['name'] as String?) ?? 'Unnamed'),
                ),
              ),
              if (_teams.isEmpty)
                const Text('No teams yet.'),
            ],
          ),
        ),
      ],
    );
  }
}

