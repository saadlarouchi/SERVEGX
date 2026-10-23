import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/api_models.dart';
import '../../providers/logs_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final _queryController = TextEditingController(
    text: 'server:"db-prod-01" AND level:(error OR warn)',
  );
  String _timeRange = 'Last 15 minutes';
  final String _sortOrder = 'Newest first';
  bool _isLiveTail = false;
  int _detailTab = 0; // 0: Fields, 1: Raw JSON
  LogModel? _selectedLog;

  final List<String> _timeRanges = [
    'Last 5 minutes',
    'Last 15 minutes',
    'Last 1 hour',
    'Last 24 hours',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsProvider = context.watch<LogsProvider>();
    final logs = logsProvider.filteredLogs;

    if (_selectedLog == null && logs.isNotEmpty) {
      _selectedLog = logs.first;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.logs,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER ──────────────────────────────────────────
            _buildHeader(),
            SizedBox(height: 20),

            // ── 2. QUERY BAR ───────────────────────────────────────
            _buildQueryBar(context, logsProvider),
            SizedBox(height: 20),

            // ── 3. LOG HISTOGRAM FREQUENCY CHART ───────────────────
            _buildHistogramCard(),
            SizedBox(height: 20),

            // ── 4. TABLE + DETAILS SPLIT VIEW ──────────────────────
            if (isDesktop && _selectedLog != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildLogTable(logs)),
                  SizedBox(width: 20),
                  Expanded(flex: 5, child: _buildLogDetailPanel(_selectedLog!)),
                ],
              )
            else
              Column(
                children: [
                  _buildLogTable(logs),
                  if (_selectedLog != null) ...[
                    SizedBox(height: 20),
                    _buildLogDetailPanel(_selectedLog!),
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

  Widget _buildHeader() {
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
              'Logs explorer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Search across your infrastructure. Find the signal in the noise.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            ServeGxButton(
              label: 'Saved queries',
              icon: Icons.bookmark_border,
              variant: ButtonVariant.secondary,
              onPressed: () => _showSavedQueriesModal(context),
            ),
            SizedBox(width: 10),
            ServeGxButton(
              label: 'Live tail',
              icon: _isLiveTail ? Icons.pause : Icons.cell_tower,
              variant: _isLiveTail
                  ? ButtonVariant.primary
                  : ButtonVariant.secondary,
              onPressed: () {
                setState(() => _isLiveTail = !_isLiveTail);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isLiveTail
                          ? 'Live tail streaming enabled'
                          : 'Live tail paused',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. QUERY BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQueryBar(BuildContext context, LogsProvider logsProvider) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Scope Chips
          Row(
            children: [
              _buildScopeChip('Core API'),
              SizedBox(width: 8),
              _buildScopeChip('db-prod-01'),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pillBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'QUERY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDim,
                  ),
                ),
              ),
              const Spacer(),
              // Time Range Selector
              Container(
                height: 32,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _timeRange,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 15,
                      color: AppColors.textDim,
                    ),
                    dropdownColor: AppColors.surfaceElevated,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    items: _timeRanges
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _timeRange = v);
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              ServeGxButton(
                label: 'Run query',
                icon: Icons.play_arrow,
                variant: ButtonVariant.primary,
                height: 32,
                onPressed: () {
                  logsProvider.setSearchQuery(_queryController.text);
                },
              ),
            ],
          ),
          SizedBox(height: 12),

          // Code/Query input line
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.codeBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.codeBorder),
            ),
            child: Row(
              children: [
                Text(
                  '1',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDim,
                    fontFamilyFallback: ['Roboto Mono', 'monospace'],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontFamilyFallback: ['Roboto Mono', 'monospace'],
                    ),
                    decoration: const InputDecoration(
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
        ],
      ),
    );
  }

  Widget _buildScopeChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.isLight ? const Color(0xFFE6F9F5) : const Color(0xFF102824),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. LOG HISTOGRAM FREQUENCY CHART
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHistogramCard() {
    return Container(
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
                  Text(
                    '122 matching events',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('·', style: TextStyle(color: AppColors.textDim)),
                  SizedBox(width: 10),
                  Text(
                    '1,248 scanned',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  SizedBox(width: 10),
                  Text('·', style: TextStyle(color: AppColors.textDim)),
                  SizedBox(width: 10),
                  Text(
                    'query took 84 ms',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '● 38 errors',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '● 84 warnings',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 18),

          // Stacked Histogram Bars
          SizedBox(
            height: 60,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const totalBars = 36;
                final barWidth =
                    (constraints.maxWidth - (totalBars * 3)) / totalBars;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(totalBars, (i) {
                    final isPeak = i >= 24;
                    final warnHeight = isPeak
                        ? (12.0 + (i % 5) * 5)
                        : (4.0 + (i % 4) * 3);
                    final errorHeight = isPeak
                        ? (8.0 + (i % 3) * 6)
                        : (2.0 + (i % 2) * 2);

                    return Container(
                      width: barWidth,
                      margin: EdgeInsets.only(right: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: errorHeight,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(1),
                              ),
                            ),
                          ),
                          Container(
                            height: warnHeight,
                            color: AppColors.warning.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          SizedBox(height: 8),

          // X-Axis Time Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '14:17',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
              Text(
                '14:20',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
              Text(
                '14:23',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
              Text(
                '14:26',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
              Text(
                '14:29',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
              Text(
                '14:32',
                style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. LOGS TABLE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLogTable(List<LogModel> logs) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Toolbar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        _sortOrder,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.wrap_text,
                        size: 16,
                        color: AppColors.textDim,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                    SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        Icons.view_column_outlined,
                        size: 16,
                        color: AppColors.textDim,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                    SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        Icons.download_outlined,
                        size: 16,
                        color: AppColors.textDim,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: AppColors.cardBorder, height: 1),

          // Table Column Headers
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    'TIME (UTC)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'LEVEL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'MESSAGE',
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

          // Log Rows
          ...logs.map((log) => _buildLogRow(log)),

          Divider(color: AppColors.cardBorder, height: 1),
          // Pagination footer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${logs.length} of 122 events',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textDim,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    'Load more events ↓',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogRow(LogModel log) {
    final isSelected = _selectedLog?.id == log.id;
    final isError = log.levelRaw.toUpperCase() == 'ERROR';
    final isWarn =
        log.levelRaw.toUpperCase() == 'WARN' ||
        log.levelRaw.toUpperCase() == 'WARNING';

    return InkWell(
      onTap: () => setState(() => _selectedLog = log),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (AppColors.isLight ? const Color(0xFFE6F9F5) : const Color(0xFF102824))
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
            left: isSelected
                ? BorderSide(color: AppColors.primary, width: 2.5)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(
                log.timestamp,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.primary,
                  fontFamilyFallback: ['Roboto Mono', 'monospace'],
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                log.levelRaw.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isError
                      ? AppColors.error
                      : (isWarn ? AppColors.warning : AppColors.info),
                  fontFamilyFallback: ['Roboto Mono', 'monospace'],
                ),
              ),
            ),
            Expanded(
              child: Text(
                log.message,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontFamilyFallback: ['Roboto Mono', 'monospace'],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. EVENT DETAILS PANEL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLogDetailPanel(LogModel log) {
    final isError = log.levelRaw.toUpperCase() == 'ERROR';

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Event details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.content_copy, size: 15, color: AppColors.textDim),
                  SizedBox(width: 10),
                  Icon(Icons.open_in_new, size: 15, color: AppColors.textDim),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Level & Timestamp
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isError ? AppColors.error : AppColors.warning)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.levelRaw.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isError ? AppColors.error : AppColors.warning,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${log.timestamp} UTC',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textDim,
                  fontFamilyFallback: ['Roboto Mono', 'monospace'],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Message headline
          Text(
            log.message,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 18),

          // Tabs: Fields | Raw JSON
          Row(
            children: [
              _buildDetailTabButton('Fields', 0),
              SizedBox(width: 16),
              _buildDetailTabButton('Raw JSON', 1),
            ],
          ),
          Divider(color: AppColors.cardBorder, height: 1),
          SizedBox(height: 16),

          // Tab content
          if (_detailTab == 0) ...[
            _buildFieldRow('server', log.relatedServer ?? 'db-prod-01'),
            SizedBox(height: 10),
            _buildFieldRow('service', log.service),
            SizedBox(height: 10),
            _buildFieldRow('project', log.relatedProject ?? 'Core API'),
            SizedBox(height: 10),
            _buildFieldRow('database', log.database),
            SizedBox(height: 10),
            _buildFieldRow('duration_ms', '${log.durationMs}'),
            SizedBox(height: 10),
            _buildFieldRow('trace_id', log.traceId),
            SizedBox(height: 10),
            _buildFieldRow('source', log.sourceFile),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.codeBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.codeBorder),
              ),
              child: Text(
                log.rawJson.isNotEmpty
                    ? log.rawJson
                    : '{\n  "timestamp": "${log.timestamp}",\n  "level": "${log.levelRaw}",\n  "server": "${log.relatedServer}",\n  "message": "${log.message}"\n}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontFamilyFallback: ['Roboto Mono', 'monospace'],
                  height: 1.4,
                ),
              ),
            ),
          ],

          SizedBox(height: 20),
          Divider(color: AppColors.cardBorder, height: 1),
          SizedBox(height: 14),

          // Related Alert banner
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.alerts),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: AppColors.error,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Related: CPU usage above 90% →',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTabButton(String label, int index) {
    final isSelected = _detailTab == index;
    return InkWell(
      onTap: () => setState(() => _detailTab = index),
      child: Container(
        padding: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldRow(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: TextStyle(
            fontSize: 11.5,
            color: AppColors.textMuted,
            fontFamilyFallback: ['Roboto Mono', 'monospace'],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamilyFallback: ['Roboto Mono', 'monospace'],
          ),
        ),
      ],
    );
  }

  void _showSavedQueriesModal(BuildContext context) {
    final queries = [
      'server:"db-prod-01" AND level:(error OR warn)',
      'service:"ingress-gw" AND http_status:>=500',
      'level:error AND message:"timeout"',
      'source:"AUTH" AND action:"mfa_failed"',
    ];

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
                'Saved queries',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Quickly execute frequent observability queries.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              SizedBox(height: 16),
              ...queries.map(
                (q) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.code,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    q,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontFamilyFallback: ['Roboto Mono', 'monospace'],
                    ),
                  ),
                  onTap: () {
                    _queryController.text = q;
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ServeGxButton(
                  label: 'Close',
                  variant: ButtonVariant.ghost,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
