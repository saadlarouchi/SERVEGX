import 'package:flutter/foundation.dart';

import '../data/models/api_models.dart';
import '../repositories/alerts_repository.dart';

class AlertsProvider extends ChangeNotifier {
  final AlertsRepository _alertsRepository;

  final Set<String> _loadingAlertIds = {};
  String _searchQuery = '';
  String _statusFilter = 'ALL'; // ALL, Active, Acknowledged, Resolved
  String _severityFilter = 'ALL'; // ALL, critical, warning, info

  Set<String> get loadingAlertIds => _loadingAlertIds;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get severityFilter => _severityFilter;

  List<AlertModel> get allAlerts => _alertsRepository.alertsListenable.value;

  List<AlertModel> get filteredAlerts {
    return allAlerts.where((a) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (a.serverName != null &&
              a.serverName!.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesStatus =
          _statusFilter == 'ALL' ||
          a.status.toLowerCase() == _statusFilter.toLowerCase();

      final matchesSeverity =
          _severityFilter == 'ALL' ||
          a.typeRaw.toLowerCase() == _severityFilter.toLowerCase();

      return matchesQuery && matchesStatus && matchesSeverity;
    }).toList();
  }

  int get totalActive =>
      allAlerts.where((a) => a.status.toLowerCase() == 'active').length;
  int get totalCritical => allAlerts
      .where(
        (a) =>
            a.typeRaw.toLowerCase() == 'critical' &&
            a.status.toLowerCase() == 'active',
      )
      .length;
  int get totalWarning => allAlerts
      .where(
        (a) =>
            a.typeRaw.toLowerCase() == 'warning' &&
            a.status.toLowerCase() == 'active',
      )
      .length;

  AlertsProvider(this._alertsRepository) {
    _alertsRepository.alertsListenable.addListener(_onAlertsUpdated);
  }

  void _onAlertsUpdated() {
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSeverityFilter(String severity) {
    _severityFilter = severity;
    notifyListeners();
  }

  bool isAlertLoading(String id) => _loadingAlertIds.contains(id);

  Future<void> acknowledgeAlert(String id) async {
    _loadingAlertIds.add(id);
    notifyListeners();

    await _alertsRepository.acknowledgeAlert(id);

    _loadingAlertIds.remove(id);
    notifyListeners();
  }

  Future<void> resolveAlert(String id) async {
    _loadingAlertIds.add(id);
    notifyListeners();

    await _alertsRepository.resolveAlert(id);

    _loadingAlertIds.remove(id);
    notifyListeners();
  }

  Future<void> deleteAlert(String id) async {
    _loadingAlertIds.add(id);
    notifyListeners();

    _alertsRepository.deleteAlert(id);

    _loadingAlertIds.remove(id);
    notifyListeners();
  }

  @override
  void dispose() {
    _alertsRepository.alertsListenable.removeListener(_onAlertsUpdated);
    super.dispose();
  }
}
