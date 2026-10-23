import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../navigation/app_routes.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 1. BRAND LOGO
// ═══════════════════════════════════════════════════════════════════════════

class ServeGxLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;

  const ServeGxLogo({
    super.key,
    this.size = 28,
    this.showText = true,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.isLight ? const Color(0xFFE6F9F5) : const Color(0xFF0F2624),
            borderRadius: BorderRadius.circular(size * 0.28),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: Size(size * 0.55, size * 0.55),
              painter: _LogoWavePainter(color: AppColors.primary),
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: 10),
          Text(
            'SERVEGX',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoWavePainter extends CustomPainter {
  final Color color;
  _LogoWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Dual stylized telemetry waveform
    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.lineTo(size.width * 0.35, size.height * 0.3);
    path1.lineTo(size.width * 0.5, size.height * 0.1);
    path1.lineTo(size.width * 0.7, size.height * 0.5);
    path1.lineTo(size.width, size.height * 0.3);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.lineTo(size.width * 0.3, size.height * 0.75);
    path2.lineTo(size.width * 0.5, size.height * 0.95);
    path2.lineTo(size.width * 0.65, size.height * 0.6);
    path2.lineTo(size.width, size.height * 0.75);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _LogoWavePainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. STATUS BADGES
// ═══════════════════════════════════════════════════════════════════════════

enum BadgeStatusType {
  critical,
  warning,
  healthy,
  online,
  stopped,
  acknowledged,
  resolved,
  info,
  firing,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatusType type;
  final bool showDot;
  final bool isPulsing;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.showDot = true,
    this.isPulsing = false,
  });

  factory StatusBadge.fromStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('crit') || s.contains('danger') || s.contains('error')) {
      return StatusBadge(label: status, type: BadgeStatusType.critical);
    }
    if (s.contains('warn')) {
      return StatusBadge(label: status, type: BadgeStatusType.warning);
    }
    if (s.contains('firing')) {
      return StatusBadge(
        label: status,
        type: BadgeStatusType.firing,
        isPulsing: true,
      );
    }
    if (s.contains('ack')) {
      return StatusBadge(label: status, type: BadgeStatusType.acknowledged);
    }
    if (s.contains('resolv')) {
      return StatusBadge(label: status, type: BadgeStatusType.resolved);
    }
    if (s.contains('on') || s.contains('run') || s.contains('health')) {
      return StatusBadge(label: status, type: BadgeStatusType.healthy);
    }
    if (s.contains('stop') || s.contains('off')) {
      return StatusBadge(label: status, type: BadgeStatusType.stopped);
    }
    return StatusBadge(label: status, type: BadgeStatusType.info);
  }

  Color get _color {
    switch (type) {
      case BadgeStatusType.critical:
      case BadgeStatusType.firing:
        return AppColors.error;
      case BadgeStatusType.warning:
        return AppColors.warning;
      case BadgeStatusType.healthy:
      case BadgeStatusType.online:
      case BadgeStatusType.resolved:
        return AppColors.success;
      case BadgeStatusType.acknowledged:
        return AppColors.blue;
      case BadgeStatusType.stopped:
        return AppColors.textMuted;
      case BadgeStatusType.info:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 3),
                ],
              ),
            ),
            SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: c,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. KPI CARDS
// ═══════════════════════════════════════════════════════════════════════════

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Widget? trailing;
  final List<double>? sparklineData;
  final Color? sparklineColor;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trailing,
    this.sparklineData,
    this.sparklineColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                      fontFamilyFallback: ['Roboto Mono', 'monospace'],
                    ),
                  ),
                ),
                if (sparklineData != null && sparklineData!.isNotEmpty)
                  SizedBox(
                    width: 72,
                    height: 28,
                    child: MiniSparkline(
                      data: sparklineData!,
                      color: sparklineColor ?? AppColors.primary,
                    ),
                  )
                else
                  ?trailing,
              ],
            ),
            SizedBox(height: 10),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. MINI SPARKLINE
// ═══════════════════════════════════════════════════════════════════════════

class MiniSparkline extends StatelessWidget {
  final List<double> data;
  final Color? color;
  final double strokeWidth;

  const MiniSparkline({
    super.key,
    required this.data,
    this.color,
    this.strokeWidth = 1.8,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(
        data: data,
        color: color ?? AppColors.primary,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;

  _SparklinePainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final linePath = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalized = (data[i] - minVal) / range;
      final y = size.height - (normalized * (size.height - 4)) - 2;

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNormalized = (data[i - 1] - minVal) / range;
        final prevY = size.height - (prevNormalized * (size.height - 4)) - 2;

        final controlX1 = prevX + (x - prevX) / 2;
        final controlX2 = prevX + (x - prevX) / 2;

        linePath.cubicTo(controlX1, prevY, controlX2, y, x, y);
        fillPath.cubicTo(controlX1, prevY, controlX2, y, x, y);
      }

      if (i == data.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. RESOURCE PROGRESS BAR
// ═══════════════════════════════════════════════════════════════════════════

class ServeGxProgressBar extends StatelessWidget {
  final double value; // 0 to 100
  final double height;
  final Color? color;
  final bool dynamicColor;

  const ServeGxProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color,
    this.dynamicColor = true,
  });

  Color _resolveColor(double v) {
    if (color != null) return color!;
    if (!dynamicColor) return AppColors.primary;
    if (v >= 90) return AppColors.error;
    if (v >= 70) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final clamped = (value / 100.0).clamp(0.0, 1.0);
    final barColor = _resolveColor(value);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF162030),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clamped,
        child: Container(
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(color: barColor.withValues(alpha: 0.4), blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. ACTION BUTTONS
// ═══════════════════════════════════════════════════════════════════════════

enum ButtonVariant { primary, secondary, outline, ghost, danger }

class ServeGxButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;
  final TextStyle? customTextStyle;

  const ServeGxButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = 36,
    this.customTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.primary;
    Color fg = const Color(0xFF041E17);
    BorderSide border = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bg = AppColors.primary;
        fg = const Color(0xFF041E17);
        break;
      case ButtonVariant.secondary:
        bg = AppColors.surfaceElevated;
        fg = AppColors.textPrimary;
        border = BorderSide(color: AppColors.cardBorder, width: 1);
        break;
      case ButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.textPrimary;
        border = BorderSide(color: AppColors.cardBorder, width: 1);
        break;
      case ButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        break;
      case ButtonVariant.danger:
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        border = BorderSide(
          color: AppColors.error.withValues(alpha: 0.4),
          width: 1,
        );
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: border,
        ),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  ),
                  SizedBox(width: 8),
                ] else if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  SizedBox(width: 7),
                ],
                Text(
                  label,
                  style:
                      customTextStyle ??
                      TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fg,
                        letterSpacing: 0.1,
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

// ═══════════════════════════════════════════════════════════════════════════
// 7. TAB BAR
// ═══════════════════════════════════════════════════════════════════════════

class ServeGxTabItem {
  final String label;
  final int? count;
  final IconData? icon;

  const ServeGxTabItem({required this.label, this.count, this.icon});
}

class ServeGxTabBar extends StatelessWidget {
  final List<ServeGxTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ServeGxTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = selectedIndex == index;
            final tab = tabs[index];

            return InkWell(
              onTap: () => onTabSelected(index),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 15,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      SizedBox(width: 7),
                    ],
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (tab.count != null) ...[
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (AppColors.isLight ? const Color(0xFFF1F5F9) : const Color(0xFF182233)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tab.count}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 8. SEARCH & COMMAND PALETTE
// ═══════════════════════════════════════════════════════════════════════════

class ServeGxSearchInput extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final double width;

  const ServeGxSearchInput({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search anything...',
    this.onTap,
    this.readOnly = false,
    this.width = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(Icons.search, size: 16, color: AppColors.textDim),
              SizedBox(width: 8),
              Expanded(
                child: readOnly
                    ? Text(
                        hintText,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textDim,
                        ),
                      )
                    : TextField(
                        controller: controller,
                        onChanged: onChanged,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textDim,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pillBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Text(
                  '⌘K',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
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

// ═══════════════════════════════════════════════════════════════════════════
// 9. COMMAND PALETTE MODAL
// ═══════════════════════════════════════════════════════════════════════════

class CommandPaletteDialog extends StatefulWidget {
  const CommandPaletteDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => const CommandPaletteDialog(),
    );
  }

  @override
  State<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<CommandPaletteDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Overview',
      'category': 'Navigate',
      'icon': Icons.grid_view,
      'route': AppRoutes.dashboard,
    },
    {
      'title': 'Servers',
      'category': 'Navigate',
      'icon': Icons.dns_outlined,
      'route': AppRoutes.serverList,
    },
    {
      'title': 'Projects',
      'category': 'Navigate',
      'icon': Icons.layers_outlined,
      'route': AppRoutes.projectList,
    },
    {
      'title': 'Alerts',
      'category': 'Navigate',
      'icon': Icons.warning_amber,
      'route': AppRoutes.alerts,
    },
    {
      'title': 'Logs explorer',
      'category': 'Navigate',
      'icon': Icons.terminal,
      'route': AppRoutes.logs,
    },
    {
      'title': 'Notifications',
      'category': 'Navigate',
      'icon': Icons.notifications_none,
      'route': AppRoutes.notifications,
    },
    {
      'title': 'Users & Access',
      'category': 'Navigate',
      'icon': Icons.people_outline,
      'route': AppRoutes.users,
    },
    {
      'title': 'Administration',
      'category': 'Navigate',
      'icon': Icons.shield_outlined,
      'route': AppRoutes.adminDashboard,
    },
    {
      'title': 'db-prod-01 (10.0.1.21)',
      'category': 'Server',
      'icon': Icons.storage,
      'route': AppRoutes.serverDetail,
    },
    {
      'title': 'worker-prod-03 (10.0.1.33)',
      'category': 'Server',
      'icon': Icons.storage,
      'route': AppRoutes.serverDetail,
    },
    {
      'title': 'api-prod-01 (10.0.0.11)',
      'category': 'Server',
      'icon': Icons.storage,
      'route': AppRoutes.serverDetail,
    },
    {
      'title': 'ALT-1042: CPU usage above 90%',
      'category': 'Alert',
      'icon': Icons.error_outline,
      'route': AppRoutes.alerts,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _quickActions.where((item) {
      final t = (item['title'] as String).toLowerCase();
      final c = (item['category'] as String).toLowerCase();
      final q = _query.toLowerCase();
      return t.contains(q) || c.contains(q);
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Container(
          width: 580,
          constraints: const BoxConstraints(maxHeight: 460),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Type a command, server name, or jump to page...',
                          hintStyle: TextStyle(
                            fontSize: 14,
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
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pillBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ESC',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.cardBorder, height: 1),
              // Results list
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No matching commands or resources found.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              item['icon'] as IconData,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            title: Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.pillBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['category'] as String,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              final route = item['route'] as String?;
                              if (route != null) {
                                Navigator.of(context)
                                    .pushReplacementNamed(route);
                              }
                            },
                          );
                        },
                      ),
              ),
              Divider(color: AppColors.cardBorder, height: 1),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SERVEGX Quick Navigation',
                      style: TextStyle(fontSize: 11, color: AppColors.textDim),
                    ),
                    Text(
                      'Use ↑ ↓ to navigate, ↵ to select',
                      style: TextStyle(fontSize: 11, color: AppColors.textDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
