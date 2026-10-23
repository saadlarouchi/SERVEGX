import 'package:flutter/foundation.dart';

import '../data/mock/mock_data_store.dart';
import '../data/models/api_models.dart';

abstract class AlertsRepository {
  ValueListenable<List<AlertModel>> get alertsListenable;
  Future<void> acknowledgeAlert(String id);
  Future<void> resolveAlert(String id);
  void deleteAlert(String id);
}

class AlertsRepositoryImpl implements AlertsRepository {
  final MockDataStore mockDataStore;

  AlertsRepositoryImpl({required this.mockDataStore});

  @override
  ValueListenable<List<AlertModel>> get alertsListenable =>
      mockDataStore.alerts;

  @override
  Future<void> acknowledgeAlert(String id) =>
      mockDataStore.acknowledgeAlert(id);

  @override
  Future<void> resolveAlert(String id) => mockDataStore.resolveAlert(id);

  @override
  void deleteAlert(String id) => mockDataStore.deleteAlert(id);
}
