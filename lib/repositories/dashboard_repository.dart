import 'package:flutter/foundation.dart';

import '../core/network/api_service.dart';
import '../data/mock/mock_data_store.dart';
import '../data/models/api_models.dart';

abstract class DashboardRepository {
  ValueListenable<MetricsModel> get metricsListenable;
  Future<ApiResult<DashboardResponse>> getDashboardStats();
  Future<ApiResult<MetricsModel>> getDashboardMetrics();
}

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiService apiService;
  final MockDataStore mockDataStore;

  DashboardRepositoryImpl({
    required this.apiService,
    required this.mockDataStore,
  });

  @override
  ValueListenable<MetricsModel> get metricsListenable =>
      mockDataStore.dashboardMetrics;

  @override
  Future<ApiResult<DashboardResponse>> getDashboardStats() async {
    final servers = mockDataStore.servers.value;
    final projects = mockDataStore.projects.value;
    final alerts = mockDataStore.alerts.value;
    final metrics = mockDataStore.dashboardMetrics.value;

    return ApiResult.success(
      DashboardResponse(
        totalServers: servers.length,
        activeServers: servers.where((s) => s.statusRaw == 'online').length,
        totalProjects: projects.length,
        totalAlerts: alerts
            .where((a) => a.status.toLowerCase() == 'active')
            .length,
        totalUsers: mockDataStore.managedUsers.value.length,
        cpuUsage: metrics.cpuUsage,
        ramUsage: metrics.ramUsage,
        diskUsage: metrics.diskUsage,
        runningProcesses: metrics.runningProcesses,
      ),
    );
  }

  @override
  Future<ApiResult<MetricsModel>> getDashboardMetrics() async {
    return ApiResult.success(mockDataStore.dashboardMetrics.value);
  }
}
