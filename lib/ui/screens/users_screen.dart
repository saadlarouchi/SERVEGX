import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_data_store.dart';
import '../../providers/admin_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';
  String _selectedRole = 'All roles';

  final List<String> _roles = [
    'All roles',
    'Owner',
    'Admin',
    'Operator',
    'Viewer',
  ];

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final users = adminProvider.users;

    final filtered = users.where((u) {
      if (_selectedRole != 'All roles' &&
          u.role.toLowerCase() != _selectedRole.toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!u.name.toLowerCase().contains(q) &&
            !u.email.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.users,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER ──────────────────────────────────────────
            _buildHeader(context, users.length),
            SizedBox(height: 20),

            // ── 2. KPI CARDS ───────────────────────────────────────
            _buildKpiRow(users, isDesktop),
            SizedBox(height: 24),

            // ── 3. FILTER TOOLBAR ──────────────────────────────────
            _buildFilterToolbar(),
            SizedBox(height: 20),

            // ── 4. MEMBERS TABLE ───────────────────────────────────
            _buildMembersTable(filtered, adminProvider),

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

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Users & Access Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Role-based access controls (RBAC) and team governance ($count members)',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        ServeGxButton(
          label: 'Invite member',
          icon: Icons.person_add_outlined,
          variant: ButtonVariant.primary,
          onPressed: () => _showInviteModal(context),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. KPI ROW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildKpiRow(List<UserItem> users, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxis = isDesktop ? 3 : 1;
        final cardWidth =
            (constraints.maxWidth - ((crossAxis - 1) * 16)) / crossAxis;

        final items = [
          KpiCard(
            title: 'Active members',
            value:
                '${users.where((u) => u.status == UserStatus.active).length}',
            subtitle: '8 total invited members across teams',
            sparklineData: [4, 5, 6, 7, 7],
            sparklineColor: AppColors.primary,
          ),
          KpiCard(
            title: 'Pending invitations',
            value: '1',
            subtitle: 'Sam Rivera (sam.rivera@acme.io)',
            trailing: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.mail_outline,
                size: 18,
                color: AppColors.warning,
              ),
            ),
          ),
          KpiCard(
            title: 'MFA coverage',
            value: '87.5%',
            subtitle: '7 of 8 members enrolled with WebAuthn/TOTP',
            sparklineData: [50, 62, 75, 87.5],
            sparklineColor: AppColors.cyan,
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
  // 3. FILTER TOOLBAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFilterToolbar() {
    return Row(
      children: [
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
                      hintText: 'Search members by name or email...',
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
        Container(
          height: 38,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 15,
                color: AppColors.textDim,
              ),
              dropdownColor: AppColors.surfaceElevated,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              items: _roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedRole = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. MEMBERS TABLE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMembersTable(List<UserItem> users, AdminProvider adminProvider) {
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
                  flex: 4,
                  child: Text(
                    'MEMBER',
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
                    'ROLE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'PROJECT ACCESS',
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
                    'MFA STATUS',
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
                    'LAST ACTIVE',
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
          ),
          Divider(color: AppColors.cardBorder, height: 1),

          ...users.map((u) {
            final isJordan =
                u.email.contains('jordan') || u.name.contains('Saad');
            final isPendingMfa =
                u.name.contains('Sam') || u.status == UserStatus.blocked;
            final initials = u.name
                .split(' ')
                .map((n) => n.isNotEmpty ? n[0] : '')
                .take(2)
                .join();

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF141C2B), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // Member name & email
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.isLight
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF162338),
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.isLight
                                  ? AppColors.textPrimary
                                  : Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                u.email,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Role
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: isJordan
                              ? (AppColors.isLight
                                  ? const Color(0xFFE6F9F5)
                                  : const Color(0xFF102824))
                              : AppColors.pillBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isJordan
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          isJordan
                              ? 'Owner'
                              : (u.role.toLowerCase().contains('admin')
                                    ? 'Admin'
                                    : 'Operator'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isJordan
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Project Access
                  Expanded(
                    flex: 3,
                    child: Text(
                      isJordan
                          ? 'All projects (Global)'
                          : 'Core API, Worker Pool',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // MFA
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusBadge(
                        label: isPendingMfa ? 'Pending' : 'Enrolled',
                        type: isPendingMfa
                            ? BadgeStatusType.warning
                            : BadgeStatusType.healthy,
                      ),
                    ),
                  ),

                  // Last active
                  Expanded(
                    flex: 2,
                    child: Text(
                      u.lastLogin,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textDim,
                      ),
                    ),
                  ),

                  // Actions
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        size: 16,
                        color: AppColors.textDim,
                      ),
                      onPressed: () => _showUserMenu(context, u, adminProvider),
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

  void _showInviteModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
                'Invite team member',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Send an invitation email to join Acme infrastructure workspace.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              SizedBox(height: 18),
              Text(
                'Work email',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 6),
              const TextField(
                decoration: InputDecoration(hintText: 'alex.rivera@acme.io'),
              ),
              SizedBox(height: 14),
              Text(
                'Role',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Operator',
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    items: [
                      DropdownMenuItem(
                        value: 'Admin',
                        child: Text('Admin (Manage servers and rules)'),
                      ),
                      DropdownMenuItem(
                        value: 'Operator',
                        child: Text('Operator (View and acknowledge alerts)'),
                      ),
                      DropdownMenuItem(
                        value: 'Viewer',
                        child: Text('Viewer (Read-only observability access)'),
                      ),
                    ],
                    onChanged: (v) {},
                  ),
                ),
              ),
              SizedBox(height: 22),
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
                    label: 'Send invite',
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invitation sent successfully'),
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

  void _showUserMenu(
    BuildContext context,
    UserItem user,
    AdminProvider provider,
  ) {
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
                  Icons.shield_outlined,
                  color: AppColors.primary,
                ),
                title: Text('Change role'),
                onTap: () => Navigator.of(ctx).pop(),
              ),
              ListTile(
                leading: Icon(Icons.mail_outline, color: AppColors.info),
                title: Text('Resend MFA activation email'),
                onTap: () => Navigator.of(ctx).pop(),
              ),
              ListTile(
                leading: Icon(Icons.block, color: AppColors.warning),
                title: Text(
                  user.status == UserStatus.active
                      ? 'Suspend access'
                      : 'Restore access',
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  provider.toggleBlockUser(user.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
