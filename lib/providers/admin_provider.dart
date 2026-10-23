import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/mock/mock_data_store.dart';
import '../data/models/notification_models.dart';
import '../repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepository;
  final MockDataStore _mockDataStore;

  bool _isSimulating = false;
  List<GlobalEvent> _recentGlobalEvents = [];
  StreamSubscription<GlobalEvent>? _eventSub;

  bool get isSimulating => _isSimulating;
  List<GlobalEvent> get recentGlobalEvents => _recentGlobalEvents;

  List<UserItem> get users => _adminRepository.usersListenable.value;
  int get activeUsersCount =>
      users.where((u) => u.status == UserStatus.active).length;
  int get blockedUsersCount =>
      users.where((u) => u.status == UserStatus.blocked).length;

  int get totalServers => _mockDataStore.servers.value.length;
  int get onlineServers =>
      _mockDataStore.servers.value.where((s) => s.statusRaw == 'online').length;
  int get offlineServers => _mockDataStore.servers.value
      .where((s) => s.statusRaw == 'offline' || s.statusRaw == 'error')
      .length;

  int get totalProjects => _mockDataStore.projects.value.length;
  int get healthyProjects =>
      _mockDataStore.projects.value.where((p) => p.health == 'Healthy').length;
  int get degradedProjects => _mockDataStore.projects.value
      .where((p) => p.health == 'Degraded' || p.health == 'Offline')
      .length;

  int get totalAlerts => _mockDataStore.alerts.value
      .where((a) => a.status.toLowerCase() == 'active')
      .length;
  int get criticalAlerts => _mockDataStore.alerts.value
      .where(
        (a) =>
            a.typeRaw.toLowerCase() == 'critical' &&
            a.status.toLowerCase() == 'active',
      )
      .length;

  int get totalLogsToday => _mockDataStore.logs.value.length;
  int get activeNotifications => _mockDataStore.notifications.value.length;

  String get healthScore {
    if (criticalAlerts > 0 || offlineServers > 0) {
      return 'Critique';
    } else if (degradedProjects > 0 || totalAlerts > 3) {
      return 'Attention';
    } else if (totalAlerts > 0) {
      return 'Bon';
    } else {
      return 'Excellent';
    }
  }

  AdminProvider(this._adminRepository, this._mockDataStore) {
    _adminRepository.usersListenable.addListener(_onDataChanged);
    _mockDataStore.servers.addListener(_onDataChanged);
    _mockDataStore.projects.addListener(_onDataChanged);
    _mockDataStore.alerts.addListener(_onDataChanged);
    _mockDataStore.logs.addListener(_onDataChanged);
    _mockDataStore.notifications.addListener(_onDataChanged);

    _eventSub = _mockDataStore.globalEvents.listen((event) {
      _recentGlobalEvents = [event, ..._recentGlobalEvents].take(10).toList();
      notifyListeners();
    });
  }

  void _onDataChanged() {
    notifyListeners();
  }

  Future<void> simulateCpuSpike() async {
    _isSimulating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));
    _adminRepository.triggerCpuSpike();

    _isSimulating = false;
    notifyListeners();
  }

  Future<void> simulateServerFailure() async {
    _isSimulating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));
    _adminRepository.triggerServerFailure();

    _isSimulating = false;
    notifyListeners();
  }

  Future<void> simulateDeploymentFailure() async {
    _isSimulating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));
    await _adminRepository.triggerDeploymentFailure();

    _isSimulating = false;
    notifyListeners();
  }

  void toggleBlockUser(String id) {
    _adminRepository.toggleBlockUser(id);
    notifyListeners();
  }

  void deleteUser(String id) {
    _adminRepository.deleteUser(id);
    notifyListeners();
  }

  void addUser({
    required String name,
    required String email,
    required String role,
  }) {
    _adminRepository.addUser(name, email, role);
    notifyListeners();
  }

  @override
  void dispose() {
    _adminRepository.usersListenable.removeListener(_onDataChanged);
    _mockDataStore.servers.removeListener(_onDataChanged);
    _mockDataStore.projects.removeListener(_onDataChanged);
    _mockDataStore.alerts.removeListener(_onDataChanged);
    _mockDataStore.logs.removeListener(_onDataChanged);
    _mockDataStore.notifications.removeListener(_onDataChanged);
    _eventSub?.cancel();
    super.dispose();
  }
}
