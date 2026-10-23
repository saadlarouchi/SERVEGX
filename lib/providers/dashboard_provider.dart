import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/mock/mock_data_store.dart';
import '../data/models/api_models.dart';
import '../data/models/notification_models.dart';
import '../repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;
  final MockDataStore _mockDataStore;

  final bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  String _systemStatus = 'Opérationnel';
  List<GlobalEvent> _recentEvents = [];

  MetricsModel get metrics => _mockDataStore.dashboardMetrics.value;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  String get systemStatus => _systemStatus;
  List<GlobalEvent> get recentEvents => _recentEvents;

  // Counts
  int get totalServers => _mockDataStore.servers.value.length;
  int get activeServers =>
      _mockDataStore.servers.value.where((s) => s.statusRaw == 'online').length;
  int get totalProjects => _mockDataStore.projects.value.length;
  int get totalAlerts => _mockDataStore.alerts.value
      .where((a) => a.status.toLowerCase() == 'active')
      .length;

  StreamSubscription<GlobalEvent>? _eventSub;

  DashboardProvider(this._dashboardRepository, this._mockDataStore) {
    _init();
  }

  void _init() {
    _mockDataStore.dashboardMetrics.addListener(_onDataChanged);
    _mockDataStore.alerts.addListener(_onDataChanged);
    _mockDataStore.servers.addListener(_onDataChanged);

    _eventSub = _mockDataStore.globalEvents.listen((event) {
      _recentEvents = [event, ..._recentEvents].take(5).toList();
      notifyListeners();
    });

    _recomputeStatus();
  }

  void _onDataChanged() {
    _recomputeStatus();
    notifyListeners();
  }

  void _recomputeStatus() {
    final alerts = _mockDataStore.alerts.value;
    final servers = _mockDataStore.servers.value;

    final criticalAlerts = alerts
        .where((a) => a.typeRaw.toLowerCase() == 'critical')
        .length;
    final warningAlerts = alerts
        .where((a) => a.typeRaw.toLowerCase() == 'warning')
        .length;
    final offlineServers = servers
        .where((s) => s.statusRaw == 'offline' || s.statusRaw == 'error')
        .length;

    if (criticalAlerts > 0 || offlineServers > 0) {
      _systemStatus = 'Critique';
    } else if (warningAlerts > 0) {
      _systemStatus = 'Dégradé';
    } else {
      _systemStatus = 'Opérationnel';
    }
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await _dashboardRepository.getDashboardMetrics();
    } catch (_) {}
    _isRefreshing = false;
    _recomputeStatus();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mockDataStore.dashboardMetrics.removeListener(_onDataChanged);
    _mockDataStore.alerts.removeListener(_onDataChanged);
    _mockDataStore.servers.removeListener(_onDataChanged);
    _eventSub?.cancel();
    super.dispose();
  }
}
