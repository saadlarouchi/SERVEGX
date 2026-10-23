import 'package:flutter/foundation.dart';

import '../data/models/notification_models.dart';
import '../repositories/notifications_repository.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository _notificationsRepository;

  String _searchQuery = '';
  String _severityFilter = 'ALL'; // ALL, INFO, SUCCESS, WARNING, CRITICAL

  String get searchQuery => _searchQuery;
  String get severityFilter => _severityFilter;

  List<NotificationModel> get allNotifications =>
      _notificationsRepository.notificationsListenable.value;

  List<NotificationModel> get filteredNotifications {
    return allNotifications.where((n) {
      final matchesSeverity =
          _severityFilter == 'ALL' ||
          n.severity.toUpperCase() == _severityFilter.toUpperCase();

      final matchesQuery =
          _searchQuery.isEmpty ||
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.message.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesSeverity && matchesQuery;
    }).toList();
  }

  int get unreadCount => allNotifications.where((n) => !n.isRead).length;

  NotificationsProvider(this._notificationsRepository) {
    _notificationsRepository.notificationsListenable.addListener(
      _onNotificationsUpdated,
    );
  }

  void _onNotificationsUpdated() {
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSeverityFilter(String severity) {
    _severityFilter = severity;
    notifyListeners();
  }

  void markAsRead(String id) {
    _notificationsRepository.markAsRead(id);
    notifyListeners();
  }

  void markAllAsRead() {
    _notificationsRepository.markAllAsRead();
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notificationsRepository.deleteNotification(id);
    notifyListeners();
  }

  void clearAll() {
    _notificationsRepository.clearAll();
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationsRepository.notificationsListenable.removeListener(
      _onNotificationsUpdated,
    );
    super.dispose();
  }
}
