import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sysmono/core/network/api_client.dart';
import 'package:sysmono/core/network/api_service.dart';
import 'package:sysmono/core/theme/app_colors.dart';
import 'package:sysmono/core/theme/app_theme.dart';
import 'package:sysmono/core/utils/token_manager.dart';
import 'package:sysmono/data/mock/mock_data_store.dart';
import 'package:sysmono/providers/admin_provider.dart';
import 'package:sysmono/providers/alerts_provider.dart';
import 'package:sysmono/providers/auth_provider.dart';
import 'package:sysmono/providers/dashboard_provider.dart';
import 'package:sysmono/providers/logs_provider.dart';
import 'package:sysmono/providers/notifications_provider.dart';
import 'package:sysmono/providers/project_provider.dart';
import 'package:sysmono/providers/server_provider.dart';
import 'package:sysmono/providers/theme_provider.dart';
import 'package:sysmono/repositories/admin_repository.dart';
import 'package:sysmono/repositories/alerts_repository.dart';
import 'package:sysmono/repositories/auth_repository.dart';
import 'package:sysmono/repositories/dashboard_repository.dart';
import 'package:sysmono/repositories/logs_repository.dart';
import 'package:sysmono/repositories/notifications_repository.dart';
import 'package:sysmono/repositories/project_repository.dart';
import 'package:sysmono/repositories/server_repository.dart';
import 'package:sysmono/ui/screens/admin_dashboard_screen.dart';
import 'package:sysmono/ui/screens/alerts_screen.dart';
import 'package:sysmono/ui/screens/create_project_screen.dart';
import 'package:sysmono/ui/screens/dashboard_screen.dart';
import 'package:sysmono/ui/screens/login_screen.dart';
import 'package:sysmono/ui/screens/logs_screen.dart';
import 'package:sysmono/ui/screens/notifications_screen.dart';
import 'package:sysmono/ui/screens/projects_list_screen.dart';
import 'package:sysmono/ui/screens/server_create_screen.dart';
import 'package:sysmono/ui/screens/server_detail_screen.dart';
import 'package:sysmono/ui/screens/server_list_screen.dart';
import 'package:sysmono/ui/screens/users_screen.dart';

void main() {
  late MockDataStore mockDataStore;
  late TokenManager tokenManager;
  late ApiService apiService;
  late AuthRepositoryImpl authRepo;
  late ServerRepositoryImpl serverRepo;
  late ProjectRepositoryImpl projectRepo;
  late DashboardRepositoryImpl dashRepo;
  late AlertsRepositoryImpl alertsRepo;
  late LogsRepositoryImpl logsRepo;
  late NotificationsRepositoryImpl notifRepo;
  late AdminRepositoryImpl adminRepo;
  late ThemeProvider themeProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'servegx_theme_mode': 'light'});
    tokenManager = await TokenManager.create();
    mockDataStore = MockDataStore.instance;
    final apiClient = ApiClient(tokenManager: tokenManager);
    apiService = ApiService(apiClient);

    authRepo = AuthRepositoryImpl(
      apiService: apiService,
      tokenManager: tokenManager,
      mockDataStore: mockDataStore,
    );
    serverRepo = ServerRepositoryImpl(
      apiService: apiService,
      mockDataStore: mockDataStore,
    );
    projectRepo = ProjectRepositoryImpl(
      apiService: apiService,
      mockDataStore: mockDataStore,
    );
    dashRepo = DashboardRepositoryImpl(
      apiService: apiService,
      mockDataStore: mockDataStore,
    );
    alertsRepo = AlertsRepositoryImpl(mockDataStore: mockDataStore);
    logsRepo = LogsRepositoryImpl(mockDataStore: mockDataStore);
    notifRepo = NotificationsRepositoryImpl(mockDataStore: mockDataStore);
    adminRepo = AdminRepositoryImpl(mockDataStore: mockDataStore);
    themeProvider = ThemeProvider(initialMode: ThemeMode.light);
    AppColors.isLight = true;
  });

  tearDown(() {
    mockDataStore.stopSimulation();
  });

  Widget buildTestScreen(Widget child, {Size size = const Size(1440, 900)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(authRepo),
          ),
          ChangeNotifierProvider<DashboardProvider>(
            create: (_) => DashboardProvider(dashRepo, mockDataStore),
          ),
          ChangeNotifierProvider<ServerProvider>(
            create: (_) => ServerProvider(serverRepo),
          ),
          ChangeNotifierProvider<ProjectProvider>(
            create: (_) => ProjectProvider(projectRepo),
          ),
          ChangeNotifierProvider<AlertsProvider>(
            create: (_) => AlertsProvider(alertsRepo),
          ),
          ChangeNotifierProvider<LogsProvider>(
            create: (_) => LogsProvider(logsRepo),
          ),
          ChangeNotifierProvider<NotificationsProvider>(
            create: (_) => NotificationsProvider(notifRepo),
          ),
          ChangeNotifierProvider<AdminProvider>(
            create: (_) => AdminProvider(adminRepo, mockDataStore),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: child,
        ),
      ),
    );
  }

  group('Light Mode Verification Across All Screens', () {
    testWidgets('Dashboard renders with no overflow in Light Mode (1440px & 390px)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(buildTestScreen(const DashboardScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      // Test mobile viewport 390px
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(buildTestScreen(const DashboardScreen(), size: const Size(390, 844)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Server List and Details render in Light Mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(buildTestScreen(const ServerListScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestScreen(const ServerDetailScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestScreen(const ServerCreateScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Projects and Create Project render in Light Mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(buildTestScreen(const ProjectsListScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestScreen(const CreateProjectScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Alerts, Logs, and Notifications render in Light Mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(buildTestScreen(const AlertsScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestScreen(const LogsScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestScreen(const NotificationsScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Users and Administration render in Light Mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(buildTestScreen(const UsersScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestScreen(const AdminDashboardScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('LoginScreen renders in Light Mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(buildTestScreen(const LoginScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  });
}
