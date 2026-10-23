import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/api_models.dart';
import '../../providers/server_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class ServerListScreen extends StatefulWidget {
  const ServerListScreen({super.key});

  @override
  State<ServerListScreen> createState() => _ServerListScreenState();
}

class _ServerListScreenState extends State<ServerListScreen> {
  String _searchQuery = '';
  String _selectedProject = 'All projects';
  String _selectedRegion = 'All regions';
  String _selectedStatus = 'All statuses';
  bool _isGridView = false;

  final List<String> _projects = [
    'All projects',
    'Core API',
    'Worker Pool',
    'Edge Gateway',
    'Analytics Engine',
  ];
  final List<String> _regions = [
    'All regions',
    'eu-west-1',
    'us-east-1',
    'ap-south-1',
  ];
  final List<String> _statuses = [
    'All statuses',
    'Online',
    'Warning',
    'Critical',
    'Stopped',
  ];

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final allServers = serverProvider.allServers;

    final filtered = allServers.where((s) {
      if (_selectedProject != 'All projects' && s.project != _selectedProject) {
        return false;
      }
      if (_selectedRegion != 'All regions' && s.region != _selectedRegion) {
        return false;
      }
      if (_selectedStatus != 'All statuses') {
        if (_selectedStatus == 'Online' && s.statusRaw != 'online') {
          return false;
        }
        if (_selectedStatus == 'Warning' && s.statusRaw != 'warning') {
          return false;
        }
        if (_selectedStatus == 'Critical' && s.statusRaw != 'critical') {
          return false;
        }
        if (_selectedStatus == 'Stopped' && s.statusRaw != 'stopped') {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!s.name.toLowerCase().contains(q) && !s.ipAddress.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.serverList,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER ──────────────────────────────────────────
            _buildHeader(context, allServers.length),
            SizedBox(height: 20),

            // ── 2. FILTER TOOLBAR ──────────────────────────────────
            _buildFiltersToolbar(),
            SizedBox(height: 20),

            // ── 3. SERVERS TABLE OR GRID ───────────────────────────
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
                        Icons.dns_outlined,
                        size: 40,
                        color: AppColors.textDim,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No matching servers',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Adjust search query or active filters to inspect hosts.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 18),
                      ServeGxButton(
                        label: 'Clear filters',
                        variant: ButtonVariant.secondary,
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedProject = 'All projects';
                            _selectedRegion = 'All regions';
                            _selectedStatus = 'All statuses';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGridView)
              _buildGridView(filtered)
            else
              _buildTableView(filtered),

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Servers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Fleet telemetry and instance health ($totalCount configured)',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        Row(
          children: [
            ServeGxButton(
              label: 'Export CSV',
              icon: Icons.download_outlined,
              variant: ButtonVariant.secondary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Exporting server telemetry to CSV...'),
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                );
              },
            ),
            SizedBox(width: 12),
            ServeGxButton(
              label: 'Add server',
              icon: Icons.add,
              variant: ButtonVariant.primary,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.serverCreate),
            ),
          ],
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
                      hintText: 'Search server name or IP...',
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

        // Project Dropdown
        _buildDropdown(
          _selectedProject,
          _projects,
          (v) => setState(() => _selectedProject = v!),
        ),
        SizedBox(width: 10),

        // Region Dropdown
        _buildDropdown(
          _selectedRegion,
          _regions,
          (v) => setState(() => _selectedRegion = v!),
        ),
        SizedBox(width: 10),

        // Status Dropdown
        _buildDropdown(
          _selectedStatus,
          _statuses,
          (v) => setState(() => _selectedStatus = v!),
        ),
        SizedBox(width: 12),

        // Grid / List toggle
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
                  Icons.table_rows_outlined,
                  size: 16,
                  color: !_isGridView ? AppColors.primary : AppColors.textDim,
                ),
                onPressed: () => setState(() => _isGridView = false),
              ),
              IconButton(
                icon: Icon(
                  Icons.grid_view,
                  size: 16,
                  color: _isGridView ? AppColors.primary : AppColors.textDim,
                ),
                onPressed: () => setState(() => _isGridView = true),
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
  // 3. TABLE VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTableView(List<ServerModel> servers) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          // Table header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'SERVER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PROJECT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'REGION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CPU',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'MEMORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'UPTIME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.cardBorder, height: 1),

          // Rows
          ...servers.map((s) => _buildTableRow(s)),
        ],
      ),
    );
  }

  Widget _buildTableRow(ServerModel server) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.serverDetail),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF141C2B), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Server Name & IP
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    server.ipAddress,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontFamilyFallback: ['Roboto Mono', 'monospace'],
                    ),
                  ),
                ],
              ),
            ),

            // Status
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge.fromStatus(server.statusRaw),
              ),
            ),

            // Project
            Expanded(
              flex: 2,
              child: Text(
                server.project,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Region
            Expanded(
              flex: 2,
              child: Text(
                server.region,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontFamilyFallback: ['Roboto Mono', 'monospace'],
                ),
              ),
            ),

            // CPU
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(right: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: ServeGxProgressBar(
                        value: server.cpuUsage,
                        height: 5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${server.cpuUsage.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Memory
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(right: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: ServeGxProgressBar(
                        value: server.ramUsage,
                        height: 5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${server.ramUsage.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Uptime
            Expanded(
              flex: 2,
              child: Text(
                '${server.uptimeHours} hrs',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textDim,
                ),
              ),
            ),

            // Actions
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.terminal_outlined,
                      size: 16,
                      color: AppColors.textDim,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    tooltip: 'Web Terminal',
                    onPressed: () => _openTerminalModal(context, server.name),
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: AppColors.textDim,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => _showServerActions(context, server),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. GRID VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildGridView(List<ServerModel> servers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 3
            : (constraints.maxWidth >= 600 ? 2 : 1);
        final itemWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * 16)) /
            crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: servers.map((s) {
            return SizedBox(
              width: itemWidth,
              child: InkWell(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.serverDetail),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.dns_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                s.name,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          StatusBadge.fromStatus(s.statusRaw),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        s.ipAddress,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textDim,
                          fontFamilyFallback: ['Roboto Mono', 'monospace'],
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CPU',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '${s.cpuUsage.toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      ServeGxProgressBar(value: s.cpuUsage, height: 5),
                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Memory',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '${s.ramUsage.toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      ServeGxProgressBar(value: s.ramUsage, height: 5),

                      SizedBox(height: 16),
                      Divider(color: AppColors.cardBorder, height: 1),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s.region,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textDim,
                            ),
                          ),
                          Text(
                            s.os,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textDim,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _openTerminalModal(BuildContext context, String serverName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF070B12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.cardBorder),
        ),
        child: Container(
          width: 600,
          height: 380,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 14),
                      Text(
                        'SSH Terminal: $serverName',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textDim,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              Divider(color: AppColors.cardBorder),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Linux 5.15.0-101-generic #111-Ubuntu SMP\n'
                    'Welcome to Ubuntu 22.04 LTS (GNU/Linux 5.15.0-101-generic x86_64)\n\n'
                    'servegx@$serverName:~\$ uptime\n'
                    ' 14:32:10 up 142 days, 16:42, 2 users, load average: 1.42, 1.38, 1.25\n\n'
                    'servegx@$serverName:~\$ systemctl status servegx-agent\n'
                    '● servegx-agent.service - SERVEGX High-Precision Telemetry Agent\n'
                    '   Loaded: loaded (/lib/systemd/system/servegx-agent.service; enabled)\n'
                    '   Active: active (running) since Tue 2026-10-20 04:00:12 UTC; 3 days ago\n'
                    '   Main PID: 1042 (servegx-agent)\n'
                    '   Tasks: 4 (limit: 18942)\n'
                    '   Memory: 24.2M\n'
                    '   CGroup: /system.slice/servegx-agent.service\n'
                    '           └─1042 /usr/local/bin/servegx-agent --endpoint=wss://telemetry.servegx.io:443\n\n'
                    'servegx@$serverName:~\$ _',
                    style: TextStyle(
                      fontFamilyFallback: ['Roboto Mono', 'monospace'],
                      fontSize: 11.5,
                      color: AppColors.primary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServerActions(BuildContext context, ServerModel server) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                ),
                title: Text('View details for ${server.name}'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamed(AppRoutes.serverDetail);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.restart_alt,
                  color: AppColors.warning,
                ),
                title: Text('Restart instance'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.read<ServerProvider>().restartServer(server.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Restart dispatched to ${server.name}'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.stop_circle_outlined,
                  color: AppColors.error,
                ),
                title: Text('Stop instance'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.read<ServerProvider>().stopServer(server.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stop command sent to ${server.name}'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
