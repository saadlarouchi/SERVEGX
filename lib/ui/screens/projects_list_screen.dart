import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/api_models.dart';
import '../../providers/project_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  String _searchQuery = '';
  String _selectedEnv = 'All environments';
  String _selectedStatus = 'All statuses';
  bool _isGridView = true;

  final List<String> _environments = [
    'All environments',
    'Production',
    'Staging',
    'Development',
  ];
  final List<String> _statuses = [
    'All statuses',
    'Healthy',
    'Degraded',
    'Stopped',
  ];

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final allProjects = projectProvider.allProjects;

    final filtered = allProjects.where((p) {
      if (_selectedEnv != 'All environments' && p.environment != _selectedEnv) {
        return false;
      }
      if (_selectedStatus != 'All statuses' && p.health != _selectedStatus) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !(p.description ?? '').toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.projectList,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER ──────────────────────────────────────────
            _buildHeader(context, allProjects.length),
            SizedBox(height: 20),

            // ── 2. FILTER TOOLBAR ──────────────────────────────────
            _buildFiltersToolbar(),
            SizedBox(height: 20),

            // ── 3. PROJECTS CARDS GRID OR LIST ─────────────────────
            if (filtered.isEmpty)
              Container(
                padding: EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.layers_outlined,
                        size: 40,
                        color: AppColors.textDim,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No matching projects',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Adjust search query or filter tags to inspect deployments.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 18),
                      ServeGxButton(
                        label: 'Create project',
                        icon: Icons.add,
                        variant: ButtonVariant.primary,
                        onPressed: () =>
                            Navigator.of(context)
                                .pushNamed(AppRoutes.projectCreate),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGridView)
              _buildGridView(filtered)
            else
              _buildListView(filtered),

            SizedBox(height: 36),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SERVEGX Cloud · eu-west-1',
                  style: TextStyle(fontSize: 11, color: AppColors.textDim),
                ),
                Text(
                  '23 OCT 2026 / 14:32:08 UTC',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textDim,
                    fontFamilyFallback: ['Roboto Mono', 'monospace'],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, int totalCount) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Projects & Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Deployment topology and release environments ($totalCount configured)',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        ServeGxButton(
          label: 'New project',
          icon: Icons.add,
          variant: ButtonVariant.primary,
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.projectCreate),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. FILTER TOOLBAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFiltersToolbar() {
    return Row(
      children: [
        // Search Input
        Expanded(
          flex: 4,
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder, width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: AppColors.textDim),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search projects or microservices...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.textDim,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10),

        // Environment dropdown
        _buildDropdown(
          _selectedEnv,
          _environments,
          (v) => setState(() => _selectedEnv = v!),
        ),
        SizedBox(width: 10),

        // Status dropdown
        _buildDropdown(
          _selectedStatus,
          _statuses,
          (v) => setState(() => _selectedStatus = v!),
        ),
        SizedBox(width: 12),

        // View mode toggle
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.grid_view,
                  size: 16,
                  color: _isGridView ? AppColors.primary : AppColors.textDim,
                ),
                onPressed: () => setState(() => _isGridView = true),
              ),
              IconButton(
                icon: Icon(
                  Icons.view_agenda_outlined,
                  size: 16,
                  color: !_isGridView ? AppColors.primary : AppColors.textDim,
                ),
                onPressed: () => setState(() => _isGridView = false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      height: 38,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 15,
            color: AppColors.textDim,
          ),
          dropdownColor: AppColors.surfaceElevated,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. GRID VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildGridView(List<ProjectModel> projects) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxis = constraints.maxWidth >= 900 ? 2 : 1;
        final cardWidth =
            (constraints.maxWidth - ((crossAxis - 1) * 16)) / crossAxis;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: projects
              .map(
                (p) => SizedBox(width: cardWidth, child: _buildProjectCard(p)),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildListView(List<ProjectModel> projects) {
    return Column(
      children: projects
          .map(
            (p) => Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: _buildProjectCard(p),
            ),
          )
          .toList(),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    final isDegraded = project.health.toLowerCase() == 'degraded';
    final serverCount = project.name.contains('Core')
        ? 8
        : (project.name.contains('Worker') ? 6 : 4);
    final cpuUsage = project.name.contains('Core')
        ? 78.0
        : (project.name.contains('Worker') ? 84.0 : 38.0);
    final memUsage = project.name.contains('Core')
        ? 72.0
        : (project.name.contains('Worker') ? 91.0 : 45.0);

    return Container(
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D2D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.layers_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            project.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pillBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              project.version,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cyan,
                                fontFamilyFallback: [
                                  'Roboto Mono',
                                  'monospace',
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        project.environment,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              StatusBadge(
                label: project.health,
                type: isDegraded
                    ? BadgeStatusType.warning
                    : BadgeStatusType.healthy,
              ),
            ],
          ),
          SizedBox(height: 12),

          // Description
          Text(
            project.description ?? 'Primary customer service stack',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 18),

          // Metrics row: CPU & Memory
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CPU Utilization',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${cpuUsage.toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    ServeGxProgressBar(value: cpuUsage, height: 5),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Memory Pressure',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${memUsage.toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    ServeGxProgressBar(value: memUsage, height: 5),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Divider(color: AppColors.cardBorder, height: 1),
          SizedBox(height: 14),

          // Deployment metadata & actions
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Icon(
                    Icons.dns_outlined,
                    size: 14,
                    color: AppColors.textDim,
                  ),
                  Text(
                    '$serverCount connected servers',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '·',
                    style: TextStyle(color: AppColors.textDim),
                  ),
                  Text(
                    project.lastDeployment,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textDim,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ServeGxButton(
                    label: 'Deploy',
                    icon: Icons.rocket_launch_outlined,
                    variant: ButtonVariant.primary,
                    height: 30,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Deploying new release to ${project.name}...',
                          ),
                          backgroundColor: AppColors.surfaceElevated,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.terminal,
                      size: 16,
                      color: AppColors.textDim,
                    ),
                    tooltip: 'Explore logs',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.logs),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
