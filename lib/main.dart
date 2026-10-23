import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/network/api_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/token_manager.dart';
import 'data/mock/mock_data_store.dart';
import 'providers/admin_provider.dart';
import 'providers/alerts_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/logs_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/project_provider.dart';
import 'providers/server_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/admin_repository.dart';
import 'repositories/alerts_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/dashboard_repository.dart';
import 'repositories/logs_repository.dart';
import 'repositories/notifications_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/server_repository.dart';
import 'ui/navigation/app_routes.dart';
import 'ui/screens/admin_dashboard_screen.dart';
import 'ui/screens/alerts_screen.dart';
import 'ui/screens/create_project_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/logs_screen.dart';
import 'ui/screens/notifications_screen.dart';
import 'ui/screens/projects_list_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/screens/server_create_screen.dart';
import 'ui/screens/server_detail_screen.dart';
import 'ui/screens/server_list_screen.dart';
import 'ui/screens/users_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenManager = await TokenManager.create();
  final mockDataStore = MockDataStore.instance;
  final apiClient = ApiClient(tokenManager: tokenManager);
  final apiService = ApiService(apiClient);

  // Repositories
  final authRepository = AuthRepositoryImpl(
    apiService: apiService,
    tokenManager: tokenManager,
    mockDataStore: mockDataStore,
  );
  final serverRepository = ServerRepositoryImpl(
    apiService: apiService,
    mockDataStore: mockDataStore,
  );
  final projectRepository = ProjectRepositoryImpl(
    apiService: apiService,
    mockDataStore: mockDataStore,
  );
  final dashboardRepository = DashboardRepositoryImpl(
    apiService: apiService,
    mockDataStore: mockDataStore,
  );
  final alertsRepository = AlertsRepositoryImpl(mockDataStore: mockDataStore);
  final logsRepository = LogsRepositoryImpl(mockDataStore: mockDataStore);
  final notificationsRepository = NotificationsRepositoryImpl(
    mockDataStore: mockDataStore,
  );
  final adminRepository = AdminRepositoryImpl(mockDataStore: mockDataStore);

  // Ensure default mock admin session is initialized if none exists
  if (!tokenManager.isLoggedIn()) {
    await tokenManager.saveToken('mock_admin_token');
    await tokenManager.saveUserInfo(
      email: 'admin@sysmonitor.com',
      name: 'Administrateur',
      role: 'admin',
    );
  }

  final initialRoute = tokenManager.isLoggedIn()
      ? AppRoutes.dashboard
      : AppRoutes.login;

  runApp(
    SysMonoApp(
      tokenManager: tokenManager,
      authRepository: authRepository,
      serverRepository: serverRepository,
      projectRepository: projectRepository,
      dashboardRepository: dashboardRepository,
      alertsRepository: alertsRepository,
      logsRepository: logsRepository,
      notificationsRepository: notificationsRepository,
      adminRepository: adminRepository,
      mockDataStore: mockDataStore,
      initialRoute: initialRoute,
    ),
  );
}

class SysMonoApp extends StatelessWidget {
  final TokenManager tokenManager;
  final AuthRepository authRepository;
  final ServerRepository serverRepository;
  final ProjectRepository projectRepository;
  final DashboardRepository dashboardRepository;
  final AlertsRepository alertsRepository;
  final LogsRepository logsRepository;
  final NotificationsRepository notificationsRepository;
  final AdminRepository adminRepository;
  final MockDataStore mockDataStore;
  final String initialRoute;

  const SysMonoApp({
    super.key,
    required this.tokenManager,
    required this.authRepository,
    required this.serverRepository,
    required this.projectRepository,
    required this.dashboardRepository,
    required this.alertsRepository,
    required this.logsRepository,
    required this.notificationsRepository,
    required this.adminRepository,
    required this.mockDataStore,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(dashboardRepository, mockDataStore),
        ),
        ChangeNotifierProvider(create: (_) => ServerProvider(serverRepository)),
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(projectRepository),
        ),
        ChangeNotifierProvider(create: (_) => AlertsProvider(alertsRepository)),
        ChangeNotifierProvider(create: (_) => LogsProvider(logsRepository)),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(notificationsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(adminRepository, mockDataStore),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SERVEGX - Server & System Management',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: initialRoute,
            routes: {
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.register: (context) => const RegisterScreen(),
              AppRoutes.dashboard: (context) => const DashboardScreen(),
              AppRoutes.serverList: (context) => const ServerListScreen(),
              AppRoutes.serverCreate: (context) => const ServerCreateScreen(),
              AppRoutes.serverDetail: (context) => const ServerDetailScreen(),
              AppRoutes.projectList: (context) => const ProjectsListScreen(),
              AppRoutes.projectCreate: (context) => const CreateProjectScreen(),
              AppRoutes.alerts: (context) => const AlertsScreen(),
              AppRoutes.logs: (context) => const LogsScreen(),
              AppRoutes.notifications: (context) => const NotificationsScreen(),
              AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
              AppRoutes.users: (context) => const UsersScreen(),
            },
          );
        },
      ),
    );
  }
}

typedef ServeGxApp = SysMonoApp;
