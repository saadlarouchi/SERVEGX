import 'package:flutter/foundation.dart';

import '../data/mock/mock_data_store.dart';
import '../data/models/notification_models.dart';

abstract class NotificationsRepository {
  ValueListenable<List<NotificationModel>> get notificationsListenable;
  Stream<GlobalEvent> get globalEvents;
  void markAsRead(String id);
  void markAllAsRead();
  void deleteNotification(String id);
  void clearAll();
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final MockDataStore mockDataStore;

  NotificationsRepositoryImpl({required this.mockDataStore});

  @override
  ValueListenable<List<NotificationModel>> get notificationsListenable =>
      mockDataStore.notifications;

  @override
  Stream<GlobalEvent> get globalEvents => mockDataStore.globalEvents;

  @override
  void markAsRead(String id) => mockDataStore.markNotificationAsRead(id);

  @override
  void markAllAsRead() => mockDataStore.markAllNotificationsAsRead();

  @override
  void deleteNotification(String id) => mockDataStore.deleteNotification(id);

  @override
  void clearAll() => mockDataStore.clearNotifications();
}
