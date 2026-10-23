import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/server_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/servegx_components.dart';

class ServerCreateScreen extends StatefulWidget {
  const ServerCreateScreen({super.key});

  @override
  State<ServerCreateScreen> createState() => _ServerCreateScreenState();
}

class _ServerCreateScreenState extends State<ServerCreateScreen> {
  final _nameController = TextEditingController(text: 'cache-redis-03');
  final _ipController = TextEditingController(text: '10.0.2.14');
  String _selectedRegion = 'eu-west-1';
  String _selectedOs = 'Ubuntu 22.04 LTS';
  String _selectedProject = 'Core API';

  String? _nameError;
  String? _ipError;

  final List<String> _regions = [
    'eu-west-1 (Frankfurt)',
    'us-east-1 (N. Virginia)',
    'ap-south-1 (Mumbai)',
  ];
  final List<String> _osList = [
    'Ubuntu 22.04 LTS',
    'Debian 12 Bookworm',
    'Alpine Linux 3.19',
    'Rocky Linux 9',
  ];
  final List<String> _projects = [
    'Core API',
    'Worker Pool',
    'Edge Gateway',
    'Analytics Engine',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _nameError = null;
      _ipError = null;
    });

    final name = _nameController.text.trim();
    final ip = _ipController.text.trim();

    if (name.isEmpty) {
      _nameError = 'Server hostname is required';
      valid = false;
    }

    if (ip.isEmpty) {
      _ipError = 'IP address is required';
      valid = false;
    }

    setState(() {});
    return valid;
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final serverProvider = context.read<ServerProvider>();
    final success = await serverProvider.createServer(
      name: _nameController.text.trim(),
      ipAddress: _ipController.text.trim(),
      os: _selectedOs,
      location: _selectedRegion.split(' ').first,
    );

    if (success && mounted) {
      serverProvider.resetCreateState();
      Navigator.of(context).pushReplacementNamed(AppRoutes.serverList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return ResponsiveScaffold(
      currentRoute: AppRoutes.serverCreate,
      customTitle: 'Add server',
      customBreadcrumbs: ['Servers', 'New server'],
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 18,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connect a new server',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Deploy the SERVEGX telemetry agent to stream host metrics in real time.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textDim),
                      onPressed: () =>
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.serverList),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Form Card
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Server hostname
                      Text(
                        'Server Hostname',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. cache-redis-03',
                          errorText: _nameError,
                        ),
                      ),
                      SizedBox(height: 18),

                      // IP address
                      Text(
                        'Private or Public IP Address',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextField(
                        controller: _ipController,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                          fontFamilyFallback: ['Roboto Mono', 'monospace'],
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 10.0.2.14',
                          errorText: _ipError,
                        ),
                      ),
                      SizedBox(height: 18),

                      // Region Dropdown
                      Text(
                        'Cloud Region',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRegion,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceElevated,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                            items: _regions
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r.split(' ').first,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedRegion = v);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 18),

                      // OS & Project row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Operating System',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedOs,
                                      isExpanded: true,
                                      dropdownColor: AppColors.surfaceElevated,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      items: _osList
                                          .map(
                                            (o) => DropdownMenuItem(
                                              value: o,
                                              child: Text(o),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() => _selectedOs = v);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Project Assignment',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedProject,
                                      isExpanded: true,
                                      dropdownColor: AppColors.surfaceElevated,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      items: _projects
                                          .map(
                                            (p) => DropdownMenuItem(
                                              value: p,
                                              child: Text(p),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() => _selectedProject = v);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Divider(color: AppColors.cardBorder, height: 1),
                      SizedBox(height: 20),

                      // One-liner agent command snippet
                      Text(
                        'Quick agent installation command',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Run this bash snippet on your host to install the telemetry daemon and link your node.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.codeBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.codeBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'curl -sSL https://get.servegx.io | sudo bash -s -- --token=sgx_tok_921fa48',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.primary,
                                  fontFamilyFallback: [
                                    'Roboto Mono',
                                    'monospace',
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.content_copy,
                              size: 15,
                              color: AppColors.textDim,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ServeGxButton(
                            label: 'Cancel',
                            variant: ButtonVariant.ghost,
                            onPressed: () =>
                                Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.serverList),
                          ),
                          SizedBox(width: 12),
                          ServeGxButton(
                            label: 'Register server',
                            icon: Icons.check,
                            variant: ButtonVariant.primary,
                            isLoading: serverProvider.isCreating,
                            onPressed: _handleSubmit,
                          ),
                        ],
                      ),
                    ],
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
