import 'package:flutter/foundation.dart';

import '../data/models/api_models.dart';
import '../repositories/logs_repository.dart';

class LogsProvider extends ChangeNotifier {
  final LogsRepository _logsRepository;

  String _searchQuery = '';
  String?
  _selectedLevel; // null or 'ALL', 'INFO', 'SUCCESS', 'WARNING', 'ERROR'
  String? _selectedSource; // null or 'ALL', 'SYSTEM', 'SERVER', 'PROJECT', 'AUTH', 'API'
  bool _isExporting = false;
  bool _showExportSuccess = false;

  String get searchQuery => _searchQuery;
  String? get selectedLevel => _selectedLevel;
  String? get selectedSource => _selectedSource;
  bool get isExporting => _isExporting;
  bool get showExportSuccess => _showExportSuccess;

  List<LogModel> get allLogs => _logsRepository.logsListenable.value;

  List<LogModel> get filteredLogs {
    return allLogs.where((log) {
      final matchesLevel =
          _selectedLevel == null ||
          _selectedLevel == 'ALL' ||
          log.level.name.toUpperCase() == _selectedLevel!.toUpperCase();

      final matchesSource =
          _selectedSource == null ||
          _selectedSource == 'ALL' ||
          log.source.name.toUpperCase() == _selectedSource!.toUpperCase();

      final matchesQuery =
          _searchQuery.isEmpty ||
          log.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (log.relatedServer?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false) ||
          (log.relatedProject?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      return matchesLevel && matchesSource && matchesQuery;
    }).toList();
  }

  int get totalLogs => allLogs.length;
  int get totalAuth => allLogs.where((l) => l.source == LogSource.auth).length;
  int get totalSuccess =>
      allLogs.where((l) => l.level == LogLevel.success).length;
  int get totalErrors => allLogs.where((l) => l.level == LogLevel.error).length;

  LogsProvider(this._logsRepository) {
    _logsRepository.logsListenable.addListener(_onLogsUpdated);
  }

  void _onLogsUpdated() {
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setLevelFilter(String? level) {
    _selectedLevel = level;
    notifyListeners();
  }

  void setSourceFilter(String? source) {
    _selectedSource = source;
    notifyListeners();
  }

  void clearLogs() {
    _logsRepository.clearLogs();
    notifyListeners();
  }

  Future<void> exportLogs() async {
    _isExporting = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _isExporting = false;
    _showExportSuccess = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));
    _showExportSuccess = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _logsRepository.logsListenable.removeListener(_onLogsUpdated);
    super.dispose();
  }
}
