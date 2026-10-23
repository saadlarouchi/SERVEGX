import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sysmono/core/network/api_client.dart';
import 'package:sysmono/core/network/api_service.dart';
import 'package:sysmono/core/utils/token_manager.dart';
import 'package:sysmono/providers/theme_provider.dart';
import 'package:sysmono/data/mock/mock_data_store.dart';
import 'package:sysmono/main.dart';
import 'package:sysmono/data/models/api_models.dart';
import 'package:sysmono/repositories/admin_repository.dart';
import 'package:sysmono/repositories/alerts_repository.dart';
import 'package:sysmono/repositories/auth_repository.dart';
import 'package:sysmono/repositories/dashboard_repository.dart';
import 'package:sysmono/repositories/logs_repository.dart';
import 'package:sysmono/repositories/notifications_repository.dart';
import 'package:sysmono/repositories/project_repository.dart';
import 'package:sysmono/repositories/server_repository.dart';
import 'package:sysmono/ui/navigation/app_routes.dart';

void main() {
  testWidgets('SYSMONO smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final tokenManager = await TokenManager.create();
    final mockDataStore = MockDataStore.instance;
    addTearDown(() => mockDataStore.stopSimulation());
    final apiClient = ApiClient(tokenManager: tokenManager);
    final apiService = ApiService(apiClient);

    final app = SysMonoApp(
      tokenManager: tokenManager,
      authRepository: AuthRepositoryImpl(
        apiService: apiService,
        tokenManager: tokenManager,
        mockDataStore: mockDataStore,
      ),
      serverRepository: ServerRepositoryImpl(
        apiService: apiService,
        mockDataStore: mockDataStore,
      ),
      projectRepository: ProjectRepositoryImpl(
        apiService: apiService,
        mockDataStore: mockDataStore,
      ),
      dashboardRepository: DashboardRepositoryImpl(
        apiService: apiService,
        mockDataStore: mockDataStore,
      ),
      alertsRepository: AlertsRepositoryImpl(mockDataStore: mockDataStore),
      logsRepository: LogsRepositoryImpl(mockDataStore: mockDataStore),
      notificationsRepository: NotificationsRepositoryImpl(
        mockDataStore: mockDataStore,
      ),
      adminRepository: AdminRepositoryImpl(mockDataStore: mockDataStore),
      mockDataStore: mockDataStore,
      initialRoute: AppRoutes.login,
    );

    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('SERVEGX'), findsWidgets);
    expect(find.text('Sign in to workspace'), findsOneWidget);

    mockDataStore.stopSimulation();
  });

  test('MockDataStore initial state has servers, projects, and metrics', () {
    final mockDataStore = MockDataStore.instance;
    addTearDown(() => mockDataStore.stopSimulation());

    expect(mockDataStore.servers.value.isNotEmpty, isTrue);
    expect(mockDataStore.projects.value.isNotEmpty, isTrue);
    expect(mockDataStore.alerts.value.isNotEmpty, isTrue);
    expect(mockDataStore.logs.value.isNotEmpty, isTrue);
    expect(
      mockDataStore.dashboardMetrics.value.cpuUsage,
      greaterThanOrEqualTo(0),
    );
    mockDataStore.stopSimulation();
  });

  test('AuthRepository authenticates valid credentials', () async {
    SharedPreferences.setMockInitialValues({});
    final tokenManager = await TokenManager.create();
    final mockDataStore = MockDataStore.instance;
    addTearDown(() => mockDataStore.stopSimulation());
    final apiClient = ApiClient(tokenManager: tokenManager);
    final apiService = ApiService(apiClient);

    final authRepo = AuthRepositoryImpl(
      apiService: apiService,
      tokenManager: tokenManager,
      mockDataStore: mockDataStore,
    );

    final result = await authRepo.login('admin@sysmonitor.com', 'admin123');
    expect(result.isSuccess, isTrue);
    expect(result.data?.user?.email, equals('admin@sysmonitor.com'));
    expect(result.data?.resolvedToken, isNotNull);
    expect(tokenManager.getToken(), isNotNull);
    mockDataStore.stopSimulation();
  });

  test('ServerRepository can fetch and create servers', () async {
    final mockDataStore = MockDataStore.instance;
    addTearDown(() => mockDataStore.stopSimulation());
    final tokenManager = await TokenManager.create();
    final apiClient = ApiClient(tokenManager: tokenManager);
    final apiService = ApiService(apiClient);

    final serverRepo = ServerRepositoryImpl(
      apiService: apiService,
      mockDataStore: mockDataStore,
    );

    final initialCount = serverRepo.serversListenable.value.length;

    final createResult = await serverRepo.createServer(
      CreateServerRequest(
        name: 'Test-Node-Alpha',
        ipAddress: '10.0.0.99',
        os: 'Debian 12',
        location: 'Frankfurt',
      ),
    );
    expect(createResult.isSuccess, isTrue);
    expect(createResult.data?.name, equals('Test-Node-Alpha'));

    expect(serverRepo.serversListenable.value.length, equals(initialCount + 1));
    mockDataStore.stopSimulation();
  });

  test('ProjectRepository can fetch and create projects', () async {
    final mockDataStore = MockDataStore.instance;
    addTearDown(() => mockDataStore.stopSimulation());
    final tokenManager = await TokenManager.create();
    final apiClient = ApiClient(tokenManager: tokenManager);
    final apiService = ApiService(apiClient);

    final projectRepo = ProjectRepositoryImpl(
      apiService: apiService,
      mockDataStore: mockDataStore,
    );

    final count = projectRepo.projectsListenable.value.length;

    final createResult = await projectRepo.createProject(
      CreateProjectRequest(
        name: 'SysMono Telemetry API',
        description: 'https://github.com/sysmono/telemetry',
        serverId: 'srv-1',
      ),
    );
    expect(createResult.isSuccess, isTrue);
    expect(createResult.data?.name, equals('SysMono Telemetry API'));

    expect(projectRepo.projectsListenable.value.length, equals(count + 1));
    mockDataStore.stopSimulation();
  });

  test('ThemeProvider toggles between dark and light mode correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider(initialMode: ThemeMode.dark);
    expect(themeProvider.isDark, isTrue);
    expect(themeProvider.isLight, isFalse);

    await themeProvider.toggleTheme();
    expect(themeProvider.isLight, isTrue);
    expect(themeProvider.isDark, isFalse);

    await themeProvider.toggleTheme();
    expect(themeProvider.isDark, isTrue);
    expect(themeProvider.isLight, isFalse);
  });
}
