import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/api_models.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/server_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimeRange = 'Last 1 hour';
  int? _hoveredChartIndex;

  final List<String> _timeRanges = [
    'Last 15 minutes',
    'Last 1 hour',
    'Last 24 hours',
    'Last 7 days',
  ];

  // Time series data points for Resource Utilization
  final List<String> _timeLabels = [
    '13:30',
    '13:45',
    '14:00',
    '14:15',
    '14:30',
  ];
  final List<double> _cpuSeries = [34.0, 38.0, 48.0, 39.0, 42.8];
  final List<double> _memSeries = [58.0, 60.5, 63.0, 61.2, 62.1];

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final serverProvider = context.watch<ServerProvider>();
    final metrics = dashboardProvider.metrics;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 700 && screenWidth < 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.dashboard,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER ROW ──────────────────────────────────────
            _buildHeader(context),
            SizedBox(height: 24),

            // ── 2. KPI CARDS GRID (4 Cards) ────────────────────────
            _buildKpiGrid(metrics, isDesktop, isTablet),
            SizedBox(height: 24),

            // ── 3. MIDDLE SECTION (Utilization & Regional Health) ──
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildUtilizationCard()),
                  SizedBox(width: 20),
                  Expanded(flex: 4, child: _buildRegionalHealthCard()),
                ],
              )
            else ...[
              _buildUtilizationCard(),
              SizedBox(height: 20),
              _buildRegionalHealthCard(),
            ],
            SizedBox(height: 24),

            // ── 4. BOTTOM SECTION (Needs Attention & Recent Events)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildNeedsAttentionCard(serverProvider),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: _buildRecentActivityCard(dashboardProvider),
                  ),
                ],
              )
            else ...[
              _buildNeedsAttentionCard(serverProvider),
              SizedBox(height: 20),
              _buildRecentActivityCard(dashboardProvider),
            ],
            SizedBox(height: 36),

            // ── 5. PAGE FOOTER ─────────────────────────────────────
            _buildFooter(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
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
              'Infrastructure overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Your entire infrastructure. One clear picture.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Time range selector
            Container(
              height: 36,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTimeRange,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textDim,
                  ),
                  dropdownColor: AppColors.surfaceElevated,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  items: _timeRanges.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 8),
                          Text(r),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedTimeRange = v);
                  },
                ),
              ),
            ),
            // Primary CTA: + Add server
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
  // 2. KPI CARDS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildKpiGrid(MetricsModel metrics, bool isDesktop, bool isTablet) {
    final int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * 16)) /
            crossAxisCount;

        final cards = [
          KpiCard(
            title: 'Connected servers',
            value: '24 / 24',
            subtitle: '22 healthy · 2 need attention',
            sparklineData: [20, 22, 24, 24, 24, 24, 24],
            sparklineColor: AppColors.primary,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.serverList),
          ),
          KpiCard(
            title: 'Average CPU',
            value: '${metrics.cpuUsage.toStringAsFixed(1)}%',
            subtitle: '↓ 4.2% from previous hour',
            sparklineData: [45.0, 48.0, 42.0, 46.0, 40.0, 42.8],
            sparklineColor: AppColors.cyan,
          ),
          KpiCard(
            title: 'Memory utilization',
            value: '${metrics.ramUsage.toStringAsFixed(1)}%',
            subtitle:
                '${metrics.ramUsedGb.toStringAsFixed(1)} GB of ${metrics.ramTotalGb.toStringAsFixed(0)} GB provisioned',
            sparklineData: [58.0, 59.0, 61.0, 60.0, 62.1],
            sparklineColor: AppColors.primary,
          ),
          KpiCard(
            title: 'Active alerts',
            value: '03',
            subtitle: '1 critical · 2 warnings',
            trailing: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: AppColors.warning,
              ),
            ),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.alerts),
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((c) => SizedBox(width: cardWidth, child: c))
              .toList(),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. RESOURCE UTILIZATION CHART
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildUtilizationCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resource utilization',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Aggregated across 24 servers',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem('CPU', AppColors.cyan),
                  SizedBox(width: 14),
                  _buildLegendItem('Memory', AppColors.primary),
                  SizedBox(width: 18),
                  Text(
                    '0–100%',
                    style: TextStyle(fontSize: 11, color: AppColors.textDim),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),

          // Custom dual-series interactive chart
          SizedBox(
            height: 180,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MouseRegion(
                  onHover: (event) {
                    final stepX =
                        constraints.maxWidth / (_timeLabels.length - 1);
                    final index = (event.localPosition.dx / stepX)
                        .round()
                        .clamp(0, _timeLabels.length - 1);
                    setState(() => _hoveredChartIndex = index);
                  },
                  onExit: (_) => setState(() => _hoveredChartIndex = null),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(constraints.maxWidth, 180),
                        painter: _MultiSeriesChartPainter(
                          cpuData: _cpuSeries,
                          memData: _memSeries,
                          hoveredIndex: _hoveredChartIndex,
                        ),
                      ),
                      if (_hoveredChartIndex != null)
                        _buildChartTooltip(
                          constraints.maxWidth,
                          _hoveredChartIndex!,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),

          // X-Axis Time Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _timeLabels.map((time) {
              return Text(
                time,
                style: TextStyle(fontSize: 11, color: AppColors.textDim),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartTooltip(double maxWidth, int index) {
    final stepX = maxWidth / (_timeLabels.length - 1);
    final xPos = (index * stepX).clamp(70.0, maxWidth - 70.0);

    return Positioned(
      left: xPos - 60,
      top: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _timeLabels[index],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textDim,
              ),
            ),
            SizedBox(height: 3),
            Row(
              children: [
                Text(
                  'CPU: ',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  '${_cpuSeries[index].toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyan,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Mem: ',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  '${_memSeries[index].toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. REGIONAL HEALTH CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRegionalHealthCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Regional health',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '3 regions',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Regions rows
          _buildRegionRow('Europe', 'eu-west-1', '12 servers', 38.0),
          SizedBox(height: 18),
          _buildRegionRow('North America', 'us-east-1', '8 servers', 53.0),
          SizedBox(height: 18),
          _buildRegionRow('Asia Pacific', 'ap-south-1', '4 servers', 34.0),

          SizedBox(height: 24),
          Divider(color: AppColors.cardBorder, height: 1),
          SizedBox(height: 14),

          // Uptime summary
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 14,
                color: AppColors.primary,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  '99.98% uptime across all regions',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegionRow(
    String name,
    String code,
    String count,
    double percent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 7),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              count,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              code,
              style: TextStyle(fontSize: 11, color: AppColors.textDim),
            ),
            SizedBox(
              width: 100,
              child: Row(
                children: [
                  Expanded(
                    child: ServeGxProgressBar(
                      value: percent,
                      height: 5,
                      dynamicColor: false,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${percent.toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. NEEDS ATTENTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNeedsAttentionCard(ServerProvider serverProvider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Needs your attention',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.serverList),
                child: Text(
                  'View all servers →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              const minTableWidth = 460.0;
              final tableContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Server',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textDim,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textDim,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'CPU',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textDim,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Memory',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textDim,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 32),
                      ],
                    ),
                  ),
                  Divider(color: AppColors.cardBorder, height: 1),

                  // 3 Attention Rows
                  _buildAttentionRow(
                    name: 'db-prod-01',
                    ip: '10.0.1.21 · us-east-1',
                    status: 'Critical',
                    cpu: 94.0,
                    memory: 88.0,
                  ),
                  Divider(color: AppColors.cardBorder, height: 1),
                  _buildAttentionRow(
                    name: 'worker-prod-03',
                    ip: '10.0.1.33 · us-east-1',
                    status: 'Warning',
                    cpu: 67.0,
                    memory: 91.0,
                  ),
                  Divider(color: AppColors.cardBorder, height: 1),
                  _buildAttentionRow(
                    name: 'api-prod-01',
                    ip: '10.0.0.11 · eu-west-1',
                    status: 'Healthy',
                    cpu: 42.0,
                    memory: 62.0,
                  ),
                ],
              );

              if (constraints.maxWidth < minTableWidth) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: minTableWidth,
                    child: tableContent,
                  ),
                );
              }
              return tableContent;
            },
          ),

          SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  '21 more servers are running within normal thresholds.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttentionRow({
    required String name,
    required String ip,
    required String status,
    required double cpu,
    required double memory,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.serverDetail),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    ip,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDim,
                      fontFamilyFallback: ['Roboto Mono', 'monospace'],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge.fromStatus(status),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Expanded(child: ServeGxProgressBar(value: cpu, height: 5)),
                    SizedBox(width: 8),
                    Text(
                      '${cpu.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ServeGxProgressBar(value: memory, height: 5),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${memory.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Icon(Icons.arrow_outward, size: 15, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. RECENT ACTIVITY
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRecentActivityCard(DashboardProvider provider) {
    final activities = [
      {
        'title': 'High CPU on db-prod-01',
        'desc': 'Core API · 2 minutes ago',
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.error,
      },
      {
        'title': 'Core API deployment completed',
        'desc': 'v2.8.4 · by Maya Chen · 18 min ago',
        'icon': Icons.rocket_launch_outlined,
        'color': AppColors.primary,
      },
      {
        'title': 'edge-prod-04 connected',
        'desc': 'Edge Gateway · 42 minutes ago',
        'icon': Icons.dns_outlined,
        'color': AppColors.info,
      },
      {
        'title': 'Daily backup completed',
        'desc': '24 of 24 servers · 1 hour ago',
        'icon': Icons.check_circle_outline,
        'color': AppColors.success,
      },
    ];

    return Container(
      padding: EdgeInsets.all(20),
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
              Expanded(
                child: Text(
                  'Recent activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notifications),
                child: Text(
                  'View all →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),

          ...activities.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Icon(
                        item['icon'] as IconData,
                        size: 15,
                        color: item['color'] as Color,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          item['desc'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
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
  // 7. FOOTER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFooter() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MULTI-SERIES CHART PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _MultiSeriesChartPainter extends CustomPainter {
  final List<double> cpuData;
  final List<double> memData;
  final int? hoveredIndex;

  _MultiSeriesChartPainter({
    required this.cpuData,
    required this.memData,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background horizontal grid lines
    final gridPaint = Paint()
      ..color = AppColors.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF131D2D)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    _drawSeries(canvas, size, cpuData, AppColors.cyan, fillAlpha: 0.12);
    _drawSeries(canvas, size, memData, AppColors.primary, fillAlpha: 0.08);

    // If an index is hovered, draw a subtle vertical cursor line
    if (hoveredIndex != null && hoveredIndex! < cpuData.length) {
      final stepX = size.width / (cpuData.length - 1);
      final x = hoveredIndex! * stepX;

      final cursorPaint = Paint()
        ..color = AppColors.isLight
            ? AppColors.textPrimary.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.25)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), cursorPaint);
    }
  }

  void _drawSeries(
    Canvas canvas,
    Size size,
    List<double> data,
    Color color, {
    double fillAlpha = 0.1,
  }) {
    if (data.length < 2) return;

    final linePath = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] / 100.0) * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - ((data[i - 1] / 100.0) * size.height);
        final cx1 = prevX + (x - prevX) / 2;
        final cx2 = prevX + (x - prevX) / 2;

        linePath.cubicTo(cx1, prevY, cx2, y, x, y);
        fillPath.cubicTo(cx1, prevY, cx2, y, x, y);
      }

      if (i == data.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    // Fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: fillAlpha),
          color.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MultiSeriesChartPainter oldDelegate) => true;
}
