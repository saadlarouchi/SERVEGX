import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/api_models.dart';
import '../../providers/project_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedEnv = 'Production';
  ServerDropdownItem? _selectedServer;
  String? _nameError;

  final List<String> _environments = ['Production', 'Staging', 'Development'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadServersForDropdown();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() => _nameError = null);
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Project name is required');
      return false;
    }
    return true;
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final projectProvider = context.read<ProjectProvider>();
    final success = await projectProvider.createProject(
      name: _nameController.text.trim(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      serverId: _selectedServer?.id,
    );

    if (success && mounted) {
      projectProvider.resetCreateState();
      Navigator.of(context).pushReplacementNamed(AppRoutes.projectList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.projectCreate,
      customTitle: 'New Project',
      customBreadcrumbs: ['Projects', 'New project'],
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a new project',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Group microservices, linked infrastructure nodes, and deployment pipelines.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textDim),
                      onPressed: () =>
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.projectList),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Name',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Ingestion Pipeline',
                          errorText: _nameError,
                        ),
                      ),
                      SizedBox(height: 18),

                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Describe purpose, SLA, and primary stakeholders...',
                        ),
                      ),
                      SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Target Environment',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedEnv,
                                      isExpanded: true,
                                      dropdownColor: AppColors.surfaceElevated,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      items: _environments
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() => _selectedEnv = v);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Primary Host Server (Optional)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<ServerDropdownItem>(
                                      value: _selectedServer,
                                      isExpanded: true,
                                      hint: Text(
                                        'Select a server...',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textDim,
                                        ),
                                      ),
                                      dropdownColor: AppColors.surfaceElevated,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      items: projectProvider.dropdownServers
                                          .map((s) {
                                            return DropdownMenuItem(
                                              value: s,
                                              child: Text(s.name),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _selectedServer = v),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ServeGxButton(
                            label: 'Cancel',
                            variant: ButtonVariant.ghost,
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.projectList),
                          ),
                          SizedBox(width: 12),
                          ServeGxButton(
                            label: 'Create project',
                            icon: Icons.check,
                            variant: ButtonVariant.primary,
                            isLoading: projectProvider.isCreating,
                            onPressed: _handleSubmit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
