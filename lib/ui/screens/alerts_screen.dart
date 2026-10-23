import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/api_models.dart';
import '../../providers/alerts_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedTabIndex = 0;
  String _selectedSeverity = 'All severities';
  String _searchQuery = '';
  AlertModel? _selectedAlert;

  final List<String> _severities = [
    'All severities',
    'Critical',
    'Warning',
    'Info',
  ];

  @override
  Widget build(BuildContext context) {
    final alertsProvider = context.watch<AlertsProvider>();
    final allAlerts = alertsProvider.allAlerts;

    // Filter alerts based on search and severity
    final activeAlerts = allAlerts.where((a) {
      if (a.isResolved) return false;
      if (_selectedSeverity != 'All severities' &&
          a.typeRaw.toLowerCase() != _selectedSeverity.toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = a.title.toLowerCase().contains(q);
        final matchDesc = a.description.toLowerCase().contains(q);
        final matchServer = (a.server ?? '').toLowerCase().contains(q);
        if (!matchTitle && !matchDesc && !matchServer) return false;
      }
      return true;
    }).toList();

    final resolvedAlerts = allAlerts.where((a) => a.isResolved).toList();

    // Default select first alert if none selected
    if (_selectedAlert == null && activeAlerts.isNotEmpty) {
      _selectedAlert = activeAlerts.first;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.alerts,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER ──────────────────────────────────────────
            _buildHeader(context),
            SizedBox(height: 20),

            // ── 2. TABS ────────────────────────────────────────────
            ServeGxTabBar(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) =>
                  setState(() => _selectedTabIndex = index),
              tabs: [
                ServeGxTabItem(
                  label: 'Active alerts',
                  count: activeAlerts.length,
                ),
                const ServeGxTabItem(label: 'Alert history'),
                const ServeGxTabItem(label: 'Rules', count: 12),
                const ServeGxTabItem(label: 'Maintenance windows'),
              ],
            ),
            SizedBox(height: 20),

            // ── 3. FILTER TOOLBAR ──────────────────────────────────
            _buildFilterToolbar(activeAlerts),
            SizedBox(height: 20),

            // ── 4. CONTENT (MASTER - DETAIL SPLIT) ──────────────────
            if (isDesktop && _selectedAlert != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Alerts List
                  Expanded(
                    flex: 6,
                    child: _buildAlertsList(activeAlerts, resolvedAlerts),
                  ),
                  SizedBox(width: 24),
                  // Right Alert Detail Drawer / Panel
                  Expanded(flex: 5, child: _buildDetailPanel(_selectedAlert!)),
                ],
              )
            else
              Column(
                children: [
                  _buildAlertsList(activeAlerts, resolvedAlerts),
                  if (_selectedAlert != null) ...[
                    SizedBox(height: 24),
                    _buildDetailPanel(_selectedAlert!),
                  ],
                ],
              ),

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
              'Alerts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'See what matters. Resolve issues before they escalate.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            ServeGxButton(
              label: 'Notification channels',
              icon: Icons.cell_tower,
              variant: ButtonVariant.secondary,
              onPressed: () => _showChannelsModal(context),
            ),
            SizedBox(width: 12),
            ServeGxButton(
              label: 'Create rule',
              icon: Icons.add,
              variant: ButtonVariant.primary,
              onPressed: () => _showCreateRuleModal(context),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. FILTER TOOLBAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFilterToolbar(List<AlertModel> activeAlerts) {
    final criticalCount = activeAlerts
        .where((a) => a.type == AlertType.critical)
        .length;
    final warningCount = activeAlerts
        .where((a) => a.type == AlertType.warning)
        .length;

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
                      hintText: 'Search alerts...',
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
        SizedBox(width: 12),

        // Severity dropdown
        Container(
          height: 38,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSeverity,
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
              items: _severities
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedSeverity = v);
              },
            ),
          ),
        ),
        SizedBox(width: 12),

        // Filters button
        ServeGxButton(
          label: 'Filters',
          icon: Icons.tune,
          variant: ButtonVariant.secondary,
          height: 38,
          onPressed: () {},
        ),
        SizedBox(width: 16),

        // Summary pills
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '● $criticalCount critical',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '● $warningCount warnings',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Sorted by severity',
          style: TextStyle(fontSize: 11.5, color: AppColors.textDim),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. ALERTS LIST (MASTER)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAlertsList(
    List<AlertModel> activeAlerts,
    List<AlertModel> resolvedAlerts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeAlerts.isEmpty)
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 36,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No active alerts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All services and server nodes are operating within configured SLO thresholds.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          ...activeAlerts.map((alert) => _buildAlertCard(alert)),

        SizedBox(height: 24),

        // Recently Resolved section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENTLY RESOLVED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textDim,
                letterSpacing: 0.8,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                'View history →',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        ...resolvedAlerts.map((alert) => _buildResolvedCard(alert)),

        SizedBox(height: 16),
        Text(
          'All times shown in UTC. Alert evaluations run every 30 seconds.',
          style: TextStyle(fontSize: 11.5, color: AppColors.textDim),
        ),
      ],
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    final isSelected = _selectedAlert?.id == alert.id;
    final isCritical = alert.type == AlertType.critical;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedAlert = alert),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.8)
                  : AppColors.cardBorder,
              width: isSelected ? 1.4 : 1.0,
            ),
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
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: isCritical ? AppColors.error : AppColors.warning,
                      ),
                      SizedBox(width: 8),
                      Text(
                        alert.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    alert.date,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textDim,
                      fontFamilyFallback: ['Roboto Mono', 'monospace'],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                alert.description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      StatusBadge(
                        label: isCritical ? 'Critical' : 'Warning',
                        type: isCritical
                            ? BadgeStatusType.critical
                            : BadgeStatusType.warning,
                        showDot: false,
                      ),
                      SizedBox(width: 8),
                      if (alert.server != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141D2D),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            alert.server!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontFamilyFallback: ['Roboto Mono', 'monospace'],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: alert.isAcknowledged
                              ? AppColors.blue
                              : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        alert.isAcknowledged ? 'Acknowledged' : 'Firing',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: alert.isAcknowledged
                              ? AppColors.blue
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResolvedCard(AlertModel alert) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.check, size: 14, color: AppColors.primary),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        alert.description,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          StatusBadge(
            label: 'Resolved',
            type: BadgeStatusType.resolved,
            showDot: false,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. DETAIL PANEL (RIGHT)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDetailPanel(AlertModel alert) {
    final isCritical = alert.type == AlertType.critical;

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
          // Top badges & ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isCritical ? AppColors.error : AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '${isCritical ? "Critical" : "Warning"} · Firing',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isCritical ? AppColors.error : AppColors.warning,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    alert.id,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDim,
                      fontFamilyFallback: ['Roboto Mono', 'monospace'],
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: AppColors.textDim,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Alert Title
          Text(
            alert.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${alert.server ?? "db-prod-01"} · ${alert.project ?? "Core API"} · ${alert.region}',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          SizedBox(height: 18),

          // Actions Row: Acknowledge, Silence, ...
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ServeGxButton(
                label: 'Acknowledge',
                icon: Icons.check,
                variant: ButtonVariant.primary,
                height: 34,
                onPressed: () {
                  context.read<AlertsProvider>().acknowledgeAlert(alert.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${alert.id} acknowledged'),
                      backgroundColor: AppColors.surfaceElevated,
                    ),
                  );
                },
              ),
              ServeGxButton(
                label: 'Silence for 1h',
                icon: Icons.notifications_off_outlined,
                variant: ButtonVariant.secondary,
                height: 34,
                onPressed: () {},
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Big Metric Readout & Threshold
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${alert.currentValue.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Threshold: ${alert.threshold.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Metric Threshold Chart
          SizedBox(
            height: 90,
            child: CustomPaint(
              size: const Size(double.infinity, 90),
              painter: _AlertThresholdChartPainter(
                data: alert.metricHistory,
                threshold: alert.threshold,
                color: isCritical ? AppColors.error : AppColors.warning,
              ),
            ),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '14:15',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
              Text(
                '14:20',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
              Text(
                '14:25',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
              Text(
                '14:30',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Metadata Grid
          _buildMetaRow(
            'Condition',
            alert.condition.isNotEmpty
                ? alert.condition
                : 'cpu.usage > 90% for 5m',
            isMonospace: true,
          ),
          SizedBox(height: 12),
          _buildMetaRow('First triggered', '23 Oct 2026, 14:30 UTC'),
          SizedBox(height: 12),
          _buildMetaRow('Assigned to', alert.assignedTo),
          SizedBox(height: 12),
          _buildMetaRow('Notified', alert.notified),

          SizedBox(height: 24),
          Divider(color: AppColors.cardBorder, height: 1),
          SizedBox(height: 16),

          // Timeline
          Text(
            'Timeline',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),

          _buildTimelineItem(
            'Alert triggered · CPU reached ${alert.currentValue.toInt()}%',
            '14:30:02 UTC · Automated',
            AppColors.error,
          ),
          SizedBox(height: 10),
          _buildTimelineItem(
            'Slack and email notifications delivered',
            '14:30:03 UTC',
            AppColors.info,
          ),

          SizedBox(height: 24),
          Divider(color: AppColors.cardBorder, height: 1),
          SizedBox(height: 16),

          // Cross links
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              InkWell(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.serverDetail),
                child: Text(
                  'Open server →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.logs),
                child: Text(
                  'Explore related logs →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, {bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamilyFallback: isMonospace
                  ? ['Roboto Mono', 'monospace']
                  : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChannelsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.cardBorder),
        ),
        child: Container(
          width: 440,
          padding: EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification channels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Configure webhook, Slack, PagerDuty, and email escalation policies.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              SizedBox(height: 18),
              _buildChannelItem(
                'Slack #infra-alerts',
                'Webhook active · Primary',
                true,
              ),
              SizedBox(height: 10),
              _buildChannelItem(
                'Email on-call@acme.io',
                'Escalation tier 1',
                true,
              ),
              SizedBox(height: 10),
              _buildChannelItem(
                'PagerDuty Service Integration',
                'Key ending in ...782c',
                false,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ServeGxButton(
                  label: 'Done',
                  variant: ButtonVariant.primary,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelItem(String name, String desc, bool isConnected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          StatusBadge(
            label: isConnected ? 'Active' : 'Configure',
            type: isConnected ? BadgeStatusType.healthy : BadgeStatusType.info,
          ),
        ],
      ),
    );
  }

  void _showCreateRuleModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.cardBorder),
        ),
        child: Container(
          width: 480,
          padding: EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create alert rule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Set telemetry thresholds and notification dispatch conditions.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              SizedBox(height: 18),
              Text(
                'Rule name',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 6),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'e.g. Memory pressure above 85%',
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Condition expression',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 6),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'e.g. mem.usage > 85% for 5m',
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ServeGxButton(
                    label: 'Cancel',
                    variant: ButtonVariant.ghost,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  SizedBox(width: 10),
                  ServeGxButton(
                    label: 'Save rule',
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Alert rule created successfully'),
                          backgroundColor: AppColors.surfaceElevated,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ALERT THRESHOLD CHART PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _AlertThresholdChartPainter extends CustomPainter {
  final List<double> data;
  final double threshold;
  final Color color;

  _AlertThresholdChartPainter({
    required this.data,
    required this.threshold,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    // Draw dashed threshold line at 90% (y = size.height * 0.25)
    final thresholdY = size.height * 0.25;
    final dashPaint = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, thresholdY),
        Offset(startX + 4, thresholdY),
        dashPaint,
      );
      startX += 8;
    }

    // Draw telemetry line
    final linePath = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      // Map 60% - 100% to canvas height
      final normalized = ((data[i] - 60.0) / 40.0).clamp(0.0, 1.0);
      final y = size.height - (normalized * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNormalized = ((data[i - 1] - 60.0) / 40.0).clamp(0.0, 1.0);
        final prevY = size.height - (prevNormalized * size.height);

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
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
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
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _AlertThresholdChartPainter oldDelegate) => true;
}
