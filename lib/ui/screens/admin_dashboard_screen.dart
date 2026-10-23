import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTabIndex = 1; // 1 is Security (default from screenshot)
  bool _requireMfa = true;
  bool _enforceSso = true;
  bool _allowPasswordSignIn = false;
  bool _restrictIp = true;
  String _sessionTimeout = '8 hours';

  final List<String> _timeouts = [
    '1 hour',
    '4 hours',
    '8 hours',
    '24 hours',
    '7 days',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.adminDashboard,
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
                ServeGxTabItem(label: 'General'),
                ServeGxTabItem(label: 'Security'),
                ServeGxTabItem(label: 'API keys'),
                ServeGxTabItem(label: 'Audit log'),
                ServeGxTabItem(label: 'Billing & usage'),
              ],
            ),
            SizedBox(height: 20),

            // ── 3. MFA WARNING BANNER ──────────────────────────────
            _buildMfaWarningBanner(),
            SizedBox(height: 20),

            // ── 4. TWO-COLUMN SECURITY SETTINGS ────────────────────
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildAuthenticationCard()),
                  SizedBox(width: 20),
                  Expanded(child: _buildSessionNetworkCard()),
                ],
              )
            else ...[
              _buildAuthenticationCard(),
              SizedBox(height: 20),
              _buildSessionNetworkCard(),
            ],
            SizedBox(height: 20),

            // ── 5. COMPLIANCE BADGES STRIP ─────────────────────────
            _buildComplianceStrip(isDesktop),
            SizedBox(height: 24),

            // ── 6. RECENT SECURITY ACTIVITY TABLE ──────────────────
            _buildRecentActivityTable(),
            SizedBox(height: 24),

            // ── 7. FOOTER ──────────────────────────────────────────
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
              'Administration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Workspace controls, security policies, and operational governance.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Owner access',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 12),
            ServeGxButton(
              label: 'View audit log',
              icon: Icons.history,
              variant: ButtonVariant.secondary,
              onPressed: () => setState(() => _selectedTabIndex = 3),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. MFA WARNING BANNER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMfaWarningBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.isLight
            ? const Color(0xFFFEF3C7)
            : const Color(0xFF26190B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: AppColors.isLight ? 0.5 : 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 20, color: AppColors.warning),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'One member still needs to enable multi-factor authentication.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFDE68A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sam Rivera has 48 hours remaining in the enrollment grace period.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFD97706)),
                ),
              ],
            ),
          ),
          ServeGxButton(
            label: 'Send reminder',
            variant: ButtonVariant.secondary,
            height: 32,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'MFA enrollment reminder sent to sam.rivera@acme.io',
                  ),
                  backgroundColor: AppColors.surfaceElevated,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. AUTHENTICATION CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAuthenticationCard() {
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
                'Authentication',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Workspace-wide',
                style: TextStyle(fontSize: 11.5, color: AppColors.textDim),
              ),
            ],
          ),
          SizedBox(height: 18),

          // Google Workspace SSO Connected Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.isLight
                  ? const Color(0xFFF8FAFC)
                  : const Color(0xFF111726),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.isLight
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF1B273A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(Icons.key, size: 16, color: AppColors.primary),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Workspace SSO',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'acme.io · Connected 02 Oct 2026',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: 'Connected', type: BadgeStatusType.healthy),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Toggles
          _buildToggleRow(
            title: 'Require multi-factor authentication',
            desc: 'All members must use an authenticator or a security key.',
            value: _requireMfa,
            onChanged: (v) => setState(() => _requireMfa = v),
          ),
          Divider(color: AppColors.cardBorder, height: 24),

          _buildToggleRow(
            title: 'Enforce single sign-on',
            desc: "Members sign in through your organization's identity provider.",
            value: _enforceSso,
            onChanged: (v) => setState(() => _enforceSso = v),
          ),
          Divider(color: AppColors.cardBorder, height: 24),

          _buildToggleRow(
            title: 'Allow password sign-in',
            desc: 'Only workspace owners can use a recovery password.',
            value: _allowPasswordSignIn,
            onChanged: (v) => setState(() => _allowPasswordSignIn = v),
          ),
          SizedBox(height: 20),
          Divider(color: AppColors.cardBorder, height: 1),
          SizedBox(height: 14),

          // Card Footer
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '7 of 8 members enrolled in MFA',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'Configure SSO →',
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. SESSION & NETWORK CONTROLS CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSessionNetworkCard() {
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
            'Session & network controls',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 18),

          // Session timeout
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
                    'Session timeout',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Require sign-in after inactivity.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
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
                    value: _sessionTimeout,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 15,
                      color: AppColors.textDim,
                    ),
                    dropdownColor: AppColors.surfaceElevated,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    items: _timeouts
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _sessionTimeout = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          Divider(color: AppColors.cardBorder, height: 24),

          // Restrict access by IP
          _buildToggleRow(
            title: 'Restrict access by IP address',
            desc: 'Only approved networks can access this workspace.',
            value: _restrictIp,
            onChanged: (v) => setState(() => _restrictIp = v),
          ),
          SizedBox(height: 14),

          // Allowed CIDRs container
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.isLight
                  ? const Color(0xFFF8FAFC)
                  : const Color(0xFF090E18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _buildCidrRow('203.0.113.0/24', 'Office network'),
                SizedBox(height: 8),
                _buildCidrRow('198.51.100.0/24', 'Corporate VPN'),
                SizedBox(height: 8),
                _buildCidrRow('192.0.2.16/28', 'CI runners'),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Manage networks & revoke sessions
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '12 active sessions · 3 approved networks',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'Manage networks →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All other active sessions revoked'),
                  backgroundColor: AppColors.surfaceElevated,
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.logout, size: 14, color: AppColors.error),
                SizedBox(width: 6),
                Text(
                  'Revoke all other sessions',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
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

  Widget _buildCidrRow(String cidr, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          cidr,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontFamilyFallback: ['Roboto Mono', 'monospace'],
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textDim),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. COMPLIANCE BADGES STRIP
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildComplianceStrip(bool isDesktop) {
    final badges = [
      {'icon': Icons.security, 'label': 'AES-256 encryption at rest'},
      {'icon': Icons.lock_outline, 'label': 'TLS 1.3 in transit'},
      {'icon': Icons.timer_outlined, 'label': '90-day audit retention'},
      {'icon': Icons.key_outlined, 'label': '3 active API keys'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 16,
        runSpacing: 10,
        children: badges
            .map(
              (b) => _buildComplianceItem(
                b['icon'] as IconData,
                b['label'] as String,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildComplianceItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. RECENT SECURITY ACTIVITY
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRecentActivityTable() {
    final events = [
      {
        'event': 'Member invitation accepted',
        'actor': 'Sam Rivera',
        'ip': '203.0.113.42',
        'time': 'Today, 14:16',
        'result': 'Success',
      },
      {
        'event': 'API key rotated: ci-deploy',
        'actor': 'Maya Chen',
        'ip': '192.0.2.20',
        'time': 'Today, 11:42',
        'result': 'Success',
      },
      {
        'event': 'Workspace security policy updated',
        'actor': 'Jordan Lee',
        'ip': '198.51.100.18',
        'time': 'Yesterday, 16:08',
        'result': 'Success',
      },
    ];

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
                'Recent security activity',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _selectedTabIndex = 3),
                child: Text(
                  'Open audit log →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Headers
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'Event',
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
                  'Actor',
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
                  'IP address',
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
                  'Time (UTC)',
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
                  'Result',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDim,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: AppColors.cardBorder, height: 20),

          ...events.map((e) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      e['event']!,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      e['actor']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      e['ip']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontFamilyFallback: ['Roboto Mono', 'monospace'],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      e['time']!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textDim,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusBadge(
                        label: e['result']!,
                        type: BadgeStatusType.healthy,
                        showDot: false,
                      ),
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
  // 8. FOOTER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.check, size: 14, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              'All changes saved · Last updated by Jordan Lee',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ),
        SizedBox(height: 14),
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
      ],
    );
  }
}
