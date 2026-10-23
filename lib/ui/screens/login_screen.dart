import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/servegx_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(text: 'jordan@acme.io');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _passwordVisible = false;
  bool _rememberMe = true;
  String? _emailError;
  String? _passwordError;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _emailError = 'Work email is required';
      valid = false;
    } else if (!email.contains('@')) {
      _emailError = 'Please enter a valid work email';
      valid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required';
      valid = false;
    }

    setState(() {});
    return valid;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    }
  }

  Future<void> _handleSsoLogin() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      'admin@sysmonitor.com',
      'admin123',
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isDesktop
          ? Row(
              children: [
                // ── LEFT HERO PANE (Topology & Brand) ─────────────
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.isLight
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF070B12),
                      border: Border(
                        right: BorderSide(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 40,
                    ),
                    child: _buildHeroSide(),
                  ),
                ),
                // ── RIGHT AUTH FORM PANE ─────────────────────────
                Expanded(
                  flex: 5,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 56,
                        vertical: 36,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: _buildAuthForm(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      const ServeGxLogo(size: 32, fontSize: 18),
                      SizedBox(height: 36),
                      _buildAuthForm(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LEFT HERO SIDE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroSide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Brand & Pill
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ServeGxLogo(size: 32, fontSize: 18),
            SizedBox(height: 48),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                'INFRASTRUCTURE, IN FOCUS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Clarity at\nevery layer.',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.1,
                letterSpacing: -0.8,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'From the first signal to the final resolution. One workspace to keep your infrastructure moving.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),

        // Middle Interactive Topology Diagram
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: _buildTopologyDiagram(),
        ),

        // Bottom Metrics & Copyright
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '99.98%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Infrastructure uptime',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 48),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '15 sec',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'From signal to visibility',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  '© 2026 SERVEGX',
                  style: TextStyle(fontSize: 11, color: AppColors.textDim),
                ),
                Text(
                  'Built for the teams keeping things running.',
                  style: TextStyle(fontSize: 11, color: AppColors.textDim),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopologyDiagram() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF090F1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONNECTED BY DESIGN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDim,
                  letterSpacing: 1.1,
                ),
              ),
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
                  SizedBox(width: 5),
                  Text(
                    'LIVE TELEMETRY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),

          // Network Nodes
          Row(
            children: [
              // Left column nodes: eu-west-1 and us-east-1
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildTopologyNode(
                      'eu-west-1',
                      '12 SERVERS ONLINE',
                      Icons.dns_outlined,
                    ),
                    SizedBox(height: 24),
                    _buildTopologyNode(
                      'us-east-1',
                      '8 SERVERS ONLINE',
                      Icons.dns_outlined,
                    ),
                  ],
                ),
              ),

              // Animated circuit lines
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) => CustomPaint(
                    size: const Size(60, 110),
                    painter: _CircuitPulsePainter(
                      progress: _animController.value,
                    ),
                  ),
                ),
              ),

              // Center Hub node: SERVEGX
              Expanded(
                flex: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.isLight
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFF0C1F22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.hub_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'SERVEGX',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ONE SOURCE OF TRUTH',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Animated circuit lines
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) => CustomPaint(
                    size: const Size(60, 110),
                    painter: _CircuitPulsePainter(
                      progress: _animController.value,
                      reverse: true,
                    ),
                  ),
                ),
              ),

              // Right column nodes: ap-south-1 and Metrics
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildTopologyNode(
                      'ap-south-1',
                      '4 SERVERS ONLINE',
                      Icons.dns_outlined,
                    ),
                    SizedBox(height: 24),
                    _buildTopologyNode(
                      'Metrics. Logs. Action.',
                      'EVERY SIGNAL, CONNECTED',
                      Icons.auto_graph_outlined,
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

  Widget _buildTopologyNode(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.isLight
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF101726),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RIGHT AUTH FORM
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAuthForm() {
    final authProvider = context.watch<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top help link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Need access? Contact your admin ↗',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ),
        SizedBox(height: 28),

        // Shield / Fingerprint icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.isLight
                ? AppColors.primary.withValues(alpha: 0.1)
                : const Color(0xFF112622),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Icon(Icons.fingerprint, size: 22, color: AppColors.primary),
          ),
        ),
        SizedBox(height: 20),

        // Titles
        Text(
          'Welcome back.',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Sign in to your SERVEGX workspace.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        SizedBox(height: 26),

        // Continue with SSO Button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: authProvider.isLoading ? null : _handleSsoLogin,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.isLight
                  ? Colors.white
                  : const Color(0xFF111726),
              side: BorderSide(color: AppColors.cardBorder, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 10),
                Text(
                  'Continue with SSO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),

        // Divider: or use your email
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.cardBorder)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or use your email',
                style: TextStyle(fontSize: 12, color: AppColors.textDim),
              ),
            ),
            Expanded(child: Divider(color: AppColors.cardBorder)),
          ],
        ),
        SizedBox(height: 20),

        // Error message if any
        if (authProvider.errorMessage != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: AppColors.error,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authProvider.errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],

        // Work email field
        Text(
          'Work email',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'jordan@acme.io',
            errorText: _emailError,
          ),
        ),
        SizedBox(height: 18),

        // Password field with forgot link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••••••',
            errorText: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textDim,
              ),
              onPressed: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
          ),
        ),
        SizedBox(height: 14),

        // Remember me
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? true),
                activeColor: AppColors.primary,
                checkColor: const Color(0xFF041E17),
                side: BorderSide(color: AppColors.cardBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Keep me signed in on this device',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
        SizedBox(height: 24),

        // Primary Action: Sign in to workspace ->
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF041E17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: authProvider.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF041E17),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign in to workspace',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 20),

        // Security badge footer
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 13, color: AppColors.textMuted),
            SizedBox(width: 6),
            Text(
              'Protected with SSO and multi-factor authentication',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(height: 36),

        // Bottom system status & privacy links
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 16,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'All systems operational',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Privacy',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textDim),
                  ),
                ),
                SizedBox(width: 12),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Terms',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textDim),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CircuitPulsePainter extends CustomPainter {
  final double progress;
  final bool reverse;

  _CircuitPulsePainter({required this.progress, this.reverse = false});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.isLight
          ? const Color(0xFFCBD5E1)
          : const Color(0xFF162338)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Center connecting horizontal path
    final path = Path();
    if (!reverse) {
      path.moveTo(0, size.height * 0.35);
      path.lineTo(size.width * 0.5, size.height * 0.5);
      path.lineTo(size.width, size.height * 0.5);

      path.moveTo(0, size.height * 0.65);
      path.lineTo(size.width * 0.5, size.height * 0.5);
    } else {
      path.moveTo(0, size.height * 0.5);
      path.lineTo(size.width * 0.5, size.height * 0.35);
      path.lineTo(size.width, size.height * 0.35);

      path.moveTo(0, size.height * 0.5);
      path.lineTo(size.width * 0.5, size.height * 0.65);
      path.lineTo(size.width, size.height * 0.65);
    }

    canvas.drawPath(path, linePaint);

    // Pulse dot
    final dotX = !reverse
        ? size.width * progress
        : size.width * (1.0 - progress);
    final dotY = size.height * 0.5;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _CircuitPulsePainter oldDelegate) => true;
}
