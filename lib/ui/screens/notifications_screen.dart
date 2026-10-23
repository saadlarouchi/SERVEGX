import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/notification_models.dart';
import '../../providers/notifications_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTabIndex = 0;
  String _searchQuery = '';

  // Preferences toggles
  bool _emailNotifs = true;
  bool _inAppNotifs = true;
  bool _slackNotifs = true;
  bool _weeklyDigest = false;
  bool _quietHours = true;

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationsProvider>();
    final notifications = notifProvider.allNotifications;

    final filtered = notifications.where((n) {
      if (_selectedTabIndex == 1 && n.isRead) return false;
      if (_selectedTabIndex == 2 && !n.message.contains('@')) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!n.title.toLowerCase().contains(q) &&
            !n.message.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.notifications,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER ──────────────────────────────────────────
            _buildHeader(context, notifProvider),
            SizedBox(height: 20),

            // ── 2. TABS ────────────────────────────────────────────
            ServeGxTabBar(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) =>
                  setState(() => _selectedTabIndex = index),
              tabs: [
                ServeGxTabItem(
                  label: 'All notifications',
                  count: notifications.length,
                ),
                ServeGxTabItem(
                  label: 'Unread',
                  count: notifProvider.unreadCount,
                ),
                const ServeGxTabItem(label: 'Mentions'),
              ],
            ),
            SizedBox(height: 20),

            // ── 3. SEARCH BAR ──────────────────────────────────────
            Container(
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
                        hintText: 'Search notifications by event, server, or author...',
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
            SizedBox(height: 20),

            // ── 4. NOTIFICATIONS LIST ──────────────────────────────
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
                        Icons.notifications_none,
                        size: 36,
                        color: AppColors.textDim,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No notifications found',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'You are all caught up with alerts, deployments, and security events.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map(
                (n) => _buildNotificationCard(context, n, notifProvider),
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

  Widget _buildHeader(BuildContext context, NotificationsProvider provider) {
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
              'Notification Center',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Real-time alerts, deployment audits, and security dispatches',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            ServeGxButton(
              label: 'Mark all as read',
              icon: Icons.done_all,
              variant: ButtonVariant.secondary,
              onPressed: () => provider.markAllAsRead(),
            ),
            SizedBox(width: 10),
            ServeGxButton(
              label: 'Preferences',
              icon: Icons.tune,
              variant: ButtonVariant.secondary,
              onPressed: () => _showPreferencesDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. NOTIFICATION CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel n,
    NotificationsProvider provider,
  ) {
    Color iconColor;
    IconData icon;
    String category;

    switch (n.severity.toUpperCase()) {
      case 'CRITICAL':
        iconColor = AppColors.error;
        icon = Icons.warning_amber_rounded;
        category = 'CRITICAL ALERT';
        break;
      case 'WARNING':
        iconColor = AppColors.warning;
        icon = Icons.warning_amber;
        category = 'WARNING';
        break;
      case 'SUCCESS':
        iconColor = AppColors.primary;
        icon = Icons.check_circle_outline;
        category = 'DEPLOYMENT';
        break;
      default:
        iconColor = AppColors.info;
        icon = Icons.info_outline;
        category = 'SERVER EVENT';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: n.isRead
            ? AppColors.cardBg
            : (AppColors.isLight ? const Color(0xFFF8FAFC) : const Color(0xFF111928)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: n.isRead
              ? AppColors.cardBorder
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Icon(icon, size: 16, color: iconColor)),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: iconColor,
                            letterSpacing: 0.8,
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
                          n.timestamp,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textDim,
                          ),
                        ),
                      ],
                    ),
                    if (!n.isRead)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  n.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  n.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (n.source == 'ALERT') {
                          Navigator.of(context).pushNamed(AppRoutes.alerts);
                        } else if (n.source == 'PROJECT') {
                          Navigator.of(context)
                              .pushNamed(AppRoutes.projectList);
                        } else {
                          Navigator.of(context).pushNamed(AppRoutes.serverList);
                        }
                      },
                      child: Text(
                        'View resource →',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    InkWell(
                      onTap: () => provider.markAsRead(n.id),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textDim,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. PREFERENCES MODAL
  // ═══════════════════════════════════════════════════════════════════════════

  void _showPreferencesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.cardBorder),
          ),
          child: Container(
            width: 460,
            padding: EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Customize delivery channels and alert notification policies.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                SizedBox(height: 20),

                _buildPrefToggle(
                  'Email notifications',
                  'Send critical incident summaries to jordan@acme.io',
                  _emailNotifs,
                  (v) {
                    setModalState(() => _emailNotifs = v);
                    setState(() => _emailNotifs = v);
                  },
                ),
                Divider(color: AppColors.cardBorder, height: 20),

                _buildPrefToggle(
                  'In-app real-time toasts',
                  'Display banner alerts when firing events occur',
                  _inAppNotifs,
                  (v) {
                    setModalState(() => _inAppNotifs = v);
                    setState(() => _inAppNotifs = v);
                  },
                ),
                Divider(color: AppColors.cardBorder, height: 20),

                _buildPrefToggle(
                  'Slack webhook dispatch',
                  'Post alert lifecycles to #infra-alerts',
                  _slackNotifs,
                  (v) {
                    setModalState(() => _slackNotifs = v);
                    setState(() => _slackNotifs = v);
                  },
                ),
                Divider(color: AppColors.cardBorder, height: 20),

                _buildPrefToggle(
                  'Weekly telemetry digest',
                  'Executive summary of SLOs, outages, and capacity',
                  _weeklyDigest,
                  (v) {
                    setModalState(() => _weeklyDigest = v);
                    setState(() => _weeklyDigest = v);
                  },
                ),
                Divider(color: AppColors.cardBorder, height: 20),

                _buildPrefToggle(
                  'Quiet hours (22:00 - 07:00 UTC)',
                  'Suppress non-critical warning notifications during night',
                  _quietHours,
                  (v) {
                    setModalState(() => _quietHours = v);
                    setState(() => _quietHours = v);
                  },
                ),
                SizedBox(height: 22),

                Align(
                  alignment: Alignment.centerRight,
                  child: ServeGxButton(
                    label: 'Save preferences',
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preferences saved successfully'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrefToggle(
    String title,
    String desc,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
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
        ),
        SizedBox(width: 14),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          inactiveThumbColor: AppColors.textDim,
          inactiveTrackColor: AppColors.isLight
              ? const Color(0xFFE2E8F0)
              : const Color(0xFF141D2D),
        ),
      ],
    );
  }
}
