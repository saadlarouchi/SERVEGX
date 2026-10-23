import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/api_models.dart';
import '../../providers/server_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class ServerDetailScreen extends StatefulWidget {
  const ServerDetailScreen({super.key});

  @override
  State<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends State<ServerDetailScreen> {
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _processes = [
    {
      'pid': 1042,
      'name': 'postgres: master process',
      'user': 'postgres',
      'cpu': 62.4,
      'mem': 38.2,
      'status': 'Running',
    },
    {
      'pid': 1088,
      'name': 'postgres: writer process',
      'user': 'postgres',
      'cpu': 18.2,
      'mem': 22.4,
      'status': 'Running',
    },
    {
      'pid': 1102,
      'name': 'postgres: walwriter',
      'user': 'postgres',
      'cpu': 8.5,
      'mem': 12.1,
      'status': 'Running',
    },
    {
      'pid': 2401,
      'name': 'servegx-agent',
      'user': 'root',
      'cpu': 1.2,
      'mem': 0.8,
      'status': 'Running',
    },
    {
      'pid': 982,
      'name': 'systemd-journald',
      'user': 'root',
      'cpu': 0.8,
      'mem': 1.2,
      'status': 'Running',
    },
    {
      'pid': 4120,
      'name': 'sshd: jordan@pts/0',
      'user': 'jordan',
      'cpu': 0.2,
      'mem': 0.4,
      'status': 'Running',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    // Default to first server or db-prod-01
    final server =
        serverProvider.currentServer ??
        serverProvider.allServers.firstWhere(
          (s) => s.name == 'db-prod-01',
          orElse: () => serverProvider.allServers.first,
        );

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.serverDetail,
      customTitle: server.name,
      customBreadcrumbs: ['Servers', server.name],
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER ──────────────────────────────────────────
            _buildHeader(context, server),
            SizedBox(height: 20),

            // ── 2. NAVIGATION TABS ─────────────────────────────────
            ServeGxTabBar(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) =>
                  setState(() => _selectedTabIndex = index),
              tabs: [
                ServeGxTabItem(label: 'Overview'),
                ServeGxTabItem(label: 'System Resources'),
                ServeGxTabItem(label: 'Processes', count: 6),
                ServeGxTabItem(label: 'Network'),
                ServeGxTabItem(label: 'Disks'),
                ServeGxTabItem(label: 'Logs'),
                ServeGxTabItem(label: 'Settings'),
              ],
            ),
            SizedBox(height: 24),

            // ── 3. METRICS OVERVIEW (CPU, RAM, Disk, Network) ──────
            _buildMetricsGrid(server, isDesktop),
            SizedBox(height: 24),

            // ── 4. PROCESSES TABLE ─────────────────────────────────
            _buildProcessesCard(),
            SizedBox(height: 24),

            // ── 5. SYSTEM INFORMATION CARD ─────────────────────────
            _buildSystemInfoCard(server),

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

  Widget _buildHeader(BuildContext context, ServerModel server) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () =>
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.serverList),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      server.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(width: 10),
                    StatusBadge.fromStatus(server.statusRaw),
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      server.ipAddress,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontFamilyFallback: ['Roboto Mono', 'monospace'],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '·',
                        style: TextStyle(color: AppColors.textDim),
                      ),
                    ),
                    Text(
                      server.project,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '·',
                        style: TextStyle(color: AppColors.textDim),
                      ),
                    ),
                    Text(
                      server.region,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '·',
                        style: TextStyle(color: AppColors.textDim),
                      ),
                    ),
                    Text(
                      'Production',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            ServeGxButton(
              label: 'Open terminal',
              icon: Icons.terminal,
              variant: ButtonVariant.secondary,
              onPressed: () => _openTerminalModal(context, server.name),
            ),
            SizedBox(width: 10),
            ServeGxButton(
              label: 'Restart',
              icon: Icons.restart_alt,
              variant: ButtonVariant.secondary,
              onPressed: () {
                context.read<ServerProvider>().restartServer(server.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Restarting ${server.name}...')),
                );
              },
            ),
            SizedBox(width: 10),
            ServeGxButton(
              label: 'Stop',
              icon: Icons.stop_circle_outlined,
              variant: ButtonVariant.danger,
              onPressed: () {
                context.read<ServerProvider>().stopServer(server.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stopping ${server.name}...')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. METRICS GRID
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMetricsGrid(ServerModel server, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxis = isDesktop ? 4 : 2;
        final cardWidth =
            (constraints.maxWidth - ((crossAxis - 1) * 16)) / crossAxis;

        final items = [
          KpiCard(
            title: 'CPU Usage',
            value: '${server.cpuUsage.toStringAsFixed(1)}%',
            subtitle: '8 vCPU (Intel Xeon Platinum)',
            sparklineData: [42, 54, 78, 88, 92, 94],
            sparklineColor: server.cpuUsage >= 90
                ? AppColors.error
                : AppColors.cyan,
          ),
          KpiCard(
            title: 'Memory Usage',
            value: '${server.ramUsage.toStringAsFixed(1)}%',
            subtitle: '14.1 GB / 16.0 GB allocated',
            sparklineData: [65, 70, 78, 84, 88],
            sparklineColor: AppColors.primary,
          ),
          KpiCard(
            title: 'Disk /var/data',
            value: '${server.diskUsage.toStringAsFixed(1)}%',
            subtitle: '174 GB / 200 GB (NVMe SSD)',
            sparklineData: [82, 83, 84, 85, 85],
            sparklineColor: AppColors.warning,
          ),
          KpiCard(
            title: 'Network Throughput',
            value: '48.2 MB/s',
            subtitle: 'Rx 32.4 MB/s · Tx 15.8 MB/s',
            sparklineData: [20, 28, 44, 38, 48],
            sparklineColor: AppColors.info,
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items
              .map((c) => SizedBox(width: cardWidth, child: c))
              .toList(),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. PROCESSES TABLE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProcessesCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active host processes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Top 6 by CPU consumption',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Header
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  'PID',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDim,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'PROCESS',
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
                  'USER',
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
                  'CPU %',
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
                  'MEM %',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDim,
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDim,
                  ),
                ),
              ),
              SizedBox(width: 40),
            ],
          ),
          Divider(color: AppColors.cardBorder, height: 20),

          ..._processes.map((p) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${p['pid']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDim,
                        fontFamilyFallback: ['Roboto Mono', 'monospace'],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      p['name'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      p['user'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${p['cpu']}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (p['cpu'] as double) >= 50.0
                            ? AppColors.error
                            : AppColors.textPrimary,
                        fontFamilyFallback: ['Roboto Mono', 'monospace'],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${p['mem']}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamilyFallback: ['Roboto Mono', 'monospace'],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusBadge(
                        label: p['status'] as String,
                        type: BadgeStatusType.healthy,
                        showDot: false,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.textDim,
                      ),
                      tooltip: 'Kill process',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Signal SIGTERM dispatched to PID ${p['pid']}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. SYSTEM INFORMATION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSystemInfoCard(ServerModel server) {
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
          Text(
            'System hardware & telemetry specs',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 18),

          Row(
            children: [
              Expanded(child: _buildInfoItem('Operating system', server.os)),
              Expanded(
                child: _buildInfoItem(
                  'Kernel',
                  'Linux 5.15.0-101-generic x86_64',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Instance type',
                  'AWS c6i.2xlarge · 8 vCPU · 16 GB',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Uptime',
                  '${server.uptimeHours} hours (~142 days)',
                ),
              ),
              Expanded(
                child: _buildInfoItem('Agent version', server.agentVersion),
              ),
              Expanded(
                child: _buildInfoItem('Last reboot', '02 Jun 2026, 04:12 UTC'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
        SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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
          width: 620,
          height: 400,
          padding: EdgeInsets.all(18),
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
                        'SSH Session: $serverName',
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
                    'Connected to db-prod-01 (10.0.1.21:22) via TLS 1.3...\n'
                    'servegx@db-prod-01:~\$ top -b -n 1 | head -n 12\n'
                    'top - 14:32:15 up 142 days, 16:42,  2 users,  load average: 1.42, 1.38, 1.25\n'
                    'Tasks: 184 total,   2 running, 182 sleeping,   0 stopped,   0 zombie\n'
                    '%Cpu(s): 94.0 us,  2.8 sy,  0.0 ni,  2.2 id,  0.8 wa,  0.0 hi,  0.2 si\n'
                    'MiB Mem :  16048.2 total,    124.0 free,  14420.2 used,   1504.0 buff/cache\n'
                    'MiB Swap:   4096.0 total,   3820.5 free,    275.5 used.   1120.4 avail Mem \n\n'
                    '  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND\n'
                    ' 1042 postgres  20   0 1482040 1.2g 480200 R  62.4  38.2 142:18.24 postgres\n'
                    ' 1088 postgres  20   0  982400 840m 320100 S  18.2  22.4  84:12.11 postgres\n'
                    ' 1102 postgres  20   0  420100 320m 140200 S   8.5  12.1  22:05.40 postgres\n\n'
                    'servegx@db-prod-01:~\$ _',
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
}
