import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/alerts_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/theme_provider.dart';
import '../navigation/app_routes.dart';
import 'servegx_components.dart';
import 'shared_components.dart';

class NavMenuItem {
  final String route;
  final String label;
  final IconData icon;
  final int? badgeCount;
  final bool showDot;

  const NavMenuItem({
    required this.route,
    required this.label,
    required this.icon,
    this.badgeCount,
    this.showDot = false,
  });
}

class ResponsiveScaffold extends StatefulWidget {
  final String currentRoute;
  final Widget body;
  final Widget? floatingActionButton;
  final String? customTitle;
  final List<String>? customBreadcrumbs;

  const ResponsiveScaffold({
    super.key,
    required this.currentRoute,
    required this.body,
    this.floatingActionButton,
    this.customTitle,
    this.customBreadcrumbs,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  bool _isSidebarCollapsed = false;

  void _navigateTo(BuildContext context, String route) {
    if (widget.currentRoute == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Sign out',
        message: 'Are you sure you want to sign out of your SERVEGX workspace?',
        confirmText: 'Sign out',
        confirmColor: AppColors.error,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
          }
        },
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _showWorkspaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.cardBorder),
        ),
        child: Container(
          width: 360,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workspaces',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Select an infrastructure workspace',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              SizedBox(height: 16),
              _buildWorkspaceItem(
                'Acme infrastructure',
                'Pro workspace · 24 servers',
                isCurrent: true,
              ),
              SizedBox(height: 8),
              _buildWorkspaceItem(
                'Staging Cluster',
                'Developer · 6 servers',
                isCurrent: false,
              ),
              SizedBox(height: 8),
              _buildWorkspaceItem(
                'Disaster Recovery',
                'Enterprise · 12 servers',
                isCurrent: false,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ServeGxButton(
                    label: 'Close',
                    variant: ButtonVariant.ghost,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspaceItem(
    String name,
    String desc, {
    required bool isCurrent,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.1)
            : (AppColors.isLight ? const Color(0xFFF8FAFC) : AppColors.surface),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : (AppColors.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF162032)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isCurrent
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
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
          if (isCurrent)
            Icon(Icons.check_circle, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
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
              Row(
                children: [
                  ServeGxLogo(size: 24, showText: false),
                  SizedBox(width: 10),
                  Text(
                    'SERVEGX Observability Hub',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Enterprise server telemetry and infrastructure monitoring platform.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              SizedBox(height: 16),
              _buildHelpRow(
                Icons.keyboard,
                'Keyboard shortcuts',
                'Press ⌘K or Ctrl+K anywhere to open the command palette.',
              ),
              SizedBox(height: 10),
              _buildHelpRow(
                Icons.cable,
                'Telemetry agents',
                'All 24 nodes stream metrics every 3 seconds to SERVEGX cloud.',
              ),
              SizedBox(height: 10),
              _buildHelpRow(
                Icons.security,
                'Security & MFA',
                'Workspace access is governed by Google Workspace SSO and IP CIDR policies.',
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ServeGxButton(
                  label: 'Got it',
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

  Widget _buildHelpRow(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: 10),
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
                body,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final sidebarWidth = _isSidebarCollapsed ? 76.0 : 260.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isDesktop
          ? Row(
              children: [
                // ── DESKTOP PERSISTENT SIDEBAR ───────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: sidebarWidth,
                  decoration: BoxDecoration(
                    color: AppColors.sidebarBg,
                    border: Border(
                      right: BorderSide(color: AppColors.cardBorder, width: 1),
                    ),
                  ),
                  child: _buildSidebarContent(
                    context,
                    isCollapsed: _isSidebarCollapsed,
                  ),
                ),
                // ── MAIN CONTENT AREA ────────────────────────────
                Expanded(
                  child: Column(
                    children: [
                      _buildDesktopTopBar(context),
                      Expanded(child: widget.body),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // ── TABLET COLLAPSED RAIL OR MOBILE APPBAR ────────
                if (isTablet)
                  Container(
                    width: 76,
                    decoration: BoxDecoration(
                      color: AppColors.sidebarBg,
                      border: Border(
                        right: BorderSide(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildSidebarContent(context, isCollapsed: true),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _buildMobileTopBar(context, showDrawerButton: !isTablet),
                      Expanded(child: widget.body),
                    ],
                  ),
                ),
              ],
            ),
      drawer: isDesktop || isTablet
          ? null
          : Drawer(
              backgroundColor: AppColors.sidebarBg,
              child: SafeArea(
                child: _buildSidebarContent(context, isCollapsed: false),
              ),
            ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIDEBAR CONTENT
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSidebarContent(
    BuildContext context, {
    required bool isCollapsed,
  }) {
    final alertsProvider = context.watch<AlertsProvider>();
    final notifsProvider = context.watch<NotificationsProvider>();
    final activeAlertCount = alertsProvider.totalActive;
    final unreadNotifs = notifsProvider.unreadCount;

    final List<NavMenuItem> workspaceItems = [
      NavMenuItem(
        route: AppRoutes.dashboard,
        label: 'Overview',
        icon: Icons.grid_view_outlined,
      ),
      NavMenuItem(
        route: AppRoutes.serverList,
        label: 'Servers',
        icon: Icons.dns_outlined,
      ),
      NavMenuItem(
        route: AppRoutes.projectList,
        label: 'Projects',
        icon: Icons.layers_outlined,
      ),
      NavMenuItem(
        route: AppRoutes.alerts,
        label: 'Alerts',
        icon: Icons.warning_amber_rounded,
        badgeCount: activeAlertCount > 0 ? activeAlertCount : 3,
      ),
      NavMenuItem(
        route: AppRoutes.logs,
        label: 'Logs explorer',
        icon: Icons.terminal_outlined,
      ),
      NavMenuItem(
        route: AppRoutes.notifications,
        label: 'Notifications',
        icon: Icons.notifications_none_outlined,
        showDot: unreadNotifs > 0,
      ),
    ];

    final List<NavMenuItem> adminItems = [
      NavMenuItem(
        route: AppRoutes.users,
        label: 'Users',
        icon: Icons.people_outline,
      ),
      NavMenuItem(
        route: AppRoutes.adminDashboard,
        label: 'Administration',
        icon: Icons.shield_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 18 : 20,
            vertical: 18,
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              ServeGxLogo(size: 28, showText: !isCollapsed, fontSize: 15),
              if (!isCollapsed)
                InkWell(
                  onTap: () => setState(() => _isSidebarCollapsed = true),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.chevron_left,
                      size: 18,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Workspace Selector Card
        if (!isCollapsed) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: InkWell(
              onTap: () => _showWorkspaceDialog(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.isLight ? const Color(0xFFF8FAFC) : const Color(0xFF111726),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1B273A),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acme infrastructure',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Pro workspace',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.unfold_more,
                      size: 15,
                      color: AppColors.textDim,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ] else ...[
          Center(
            child: InkWell(
              onTap: () => setState(() => _isSidebarCollapsed = false),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.isLight ? const Color(0xFFF8FAFC) : const Color(0xFF111726),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],

        // Nav Section: WORKSPACE
        if (!isCollapsed)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDim,
                letterSpacing: 1.2,
              ),
            ),
          ),

        // Workspace Menu Items
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 10),
            children: [
              ...workspaceItems.map(
                (item) => _buildNavItem(context, item, isCollapsed),
              ),
              SizedBox(height: 16),
              if (!isCollapsed)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    'ADMINISTRATION',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ...adminItems.map(
                (item) => _buildNavItem(context, item, isCollapsed),
              ),
            ],
          ),
        ),

        // Bottom Agent Status Card
        if (!isCollapsed)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0F1624),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All agents connected',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Last sync 4 seconds ago',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // User Profile Footer
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 12 : 14,
            vertical: 12,
          ),
          child: InkWell(
            onTap: () => _showUserMenu(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 6 : 8,
                vertical: 6,
              ),
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                    child: Text(
                      'JL',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.isLight ? AppColors.textPrimary : Colors.white,
                      ),
                    ),
                  ),
                  if (!isCollapsed) ...[
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jordan Lee',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Workspace owner',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.textDim,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavMenuItem item,
    bool isCollapsed,
  ) {
    final isSelected = widget.currentRoute == item.route;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Tooltip(
        message: isCollapsed ? item.label : '',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () => _navigateTo(context, item.route),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 14 : 12,
                vertical: 8.5,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.activeItemBg
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    item.icon,
                    size: 18,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  if (!isCollapsed) ...[
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (item.badgeCount != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.isLight
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFF332014),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '${item.badgeCount}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      )
                    else if (item.showDot)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.isLight ? const Color(0xFFE2E8F0) : AppColors.cardBorder,
                  child: Text(
                    'JL',
                    style: TextStyle(
                      color: AppColors.isLight ? AppColors.textPrimary : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  'Jordan Lee',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Workspace owner · jordan@acme.io',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
              Divider(color: AppColors.cardBorder),
              ListTile(
                leading: Icon(
                  context.watch<ThemeProvider>().isLight
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                title: Text(
                  context.watch<ThemeProvider>().isLight
                      ? 'Switch to Dark Mode'
                      : 'Switch to Light Mode',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.pillBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    context.watch<ThemeProvider>().isLight ? 'Light' : 'Dark',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                onTap: () {
                  context.read<ThemeProvider>().toggleTheme();
                  Navigator.of(ctx).pop();
                },
              ),
              Divider(color: AppColors.cardBorder),
              ListTile(
                leading: Icon(
                  Icons.tune_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                title: Text(
                  'Workspace preferences',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _navigateTo(context, AppRoutes.adminDashboard);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.people_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                title: Text(
                  'Manage team members',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _navigateTo(context, AppRoutes.users);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 20,
                ),
                title: Text(
                  'Sign out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP BARS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDesktopTopBar(BuildContext context) {
    final breadcrumb = _getBreadcrumbPath();
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Breadcrumbs
          Row(
            children: [
              Text(
                'Workspace',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '/',
                  style: TextStyle(fontSize: 12, color: AppColors.textDim),
                ),
              ),
              Text(
                breadcrumb,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Right Controls: Search, Help, Notifications, Live Indicator
          Row(
            children: [
              ServeGxSearchInput(
                readOnly: true,
                onTap: () => CommandPaletteDialog.show(context),
              ),
              SizedBox(width: 14),
              // Theme Toggle Button
              IconButton(
                key: const ValueKey('desktop_theme_toggle_btn'),
                icon: Icon(
                  themeProvider.isLight
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  size: 19,
                  color: AppColors.textSecondary,
                ),
                tooltip: themeProvider.isLight
                    ? 'Switch to Dark Mode'
                    : 'Switch to Light Mode',
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
              ),
              IconButton(
                icon: Icon(
                  Icons.help_outline,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                tooltip: 'Documentation & Help',
                onPressed: () => _showHelpDialog(context),
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                tooltip: 'Notifications',
                onPressed: () => _navigateTo(context, AppRoutes.notifications),
              ),
              SizedBox(width: 10),
              // Live Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.isLight ? const Color(0xFFE6F9F5) : const Color(0xFF0D251D),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: AppColors.isLight ? 0.4 : 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTopBar(
    BuildContext context, {
    required bool showDrawerButton,
  }) {
    final title = widget.customTitle ?? AppRoutes.getTitle(widget.currentRoute);

    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showDrawerButton)
                IconButton(
                  icon: Icon(Icons.menu, color: AppColors.textPrimary),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              const ServeGxLogo(size: 24, showText: false),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                key: const ValueKey('mobile_theme_toggle_btn'),
                icon: Icon(
                  context.watch<ThemeProvider>().isLight
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Toggle theme',
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => CommandPaletteDialog.show(context),
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => _navigateTo(context, AppRoutes.notifications),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getBreadcrumbPath() {
    if (widget.customBreadcrumbs != null &&
        widget.customBreadcrumbs!.isNotEmpty) {
      return widget.customBreadcrumbs!.join(' / ');
    }
    switch (widget.currentRoute) {
      case AppRoutes.dashboard:
        return 'Overview';
      case AppRoutes.serverList:
        return 'Servers';
      case AppRoutes.serverDetail:
        return 'Servers / db-prod-01';
      case AppRoutes.serverCreate:
        return 'Servers / New server';
      case AppRoutes.projectList:
        return 'Projects';
      case AppRoutes.projectCreate:
        return 'Projects / New project';
      case AppRoutes.alerts:
        return 'Alerts';
      case AppRoutes.logs:
        return 'Logs explorer';
      case AppRoutes.notifications:
        return 'Notifications';
      case AppRoutes.adminDashboard:
        return 'Administration';
      case AppRoutes.users:
        return 'Users & Access';
      default:
        return 'Overview';
    }
  }
}
