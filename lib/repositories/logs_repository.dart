import 'package:flutter/foundation.dart';

import '../data/mock/mock_data_store.dart';
import '../data/models/api_models.dart';

abstract class LogsRepository {
  ValueListenable<List<LogModel>> get logsListenable;
  void addLog(
    String level,
    String source,
    String message, {
    String? server,
    String? project,
  });
  void clearLogs();
}

class LogsRepositoryImpl implements LogsRepository {
  final MockDataStore mockDataStore;

  LogsRepositoryImpl({required this.mockDataStore});

  @override
  ValueListenable<List<LogModel>> get logsListenable => mockDataStore.logs;

  @override
  void addLog(
    String level,
    String source,
    String message, {
    String? server,
    String? project,
  }) {
    mockDataStore.addLog(
      level,
      source,
      message,
      server: server,
      project: project,
    );
  }

  @override
  void clearLogs() {
    mockDataStore.clearLogs();
  }
}
