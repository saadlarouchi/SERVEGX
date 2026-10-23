import 'package:flutter/foundation.dart';

import '../data/models/api_models.dart';
import '../repositories/server_repository.dart';

class ServerProvider extends ChangeNotifier {
  final ServerRepository _serverRepository;

  final bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _statusFilter; // null = all, 'online', 'offline', 'error'

  // Create state
  bool _isCreating = false;
  bool _createSuccess = false;
  String? _createError;

  // Detail & Action state
  String? _currentDetailId;
  bool _isActionLoading = false;
  String? _actionSuccess;
  String? _actionError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;

  bool get isCreating => _isCreating;
  bool get createSuccess => _createSuccess;
  String? get createError => _createError;

  bool get isActionLoading => _isActionLoading;
  String? get actionSuccess => _actionSuccess;
  String? get actionError => _actionError;

  List<ServerModel> get allServers => _serverRepository.serversListenable.value;

  List<ServerModel> get filteredServers {
    return allServers.where((s) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.ipAddress.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.location.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _statusFilter == null ||
          _statusFilter!.isEmpty ||
          _statusFilter == 'ALL' ||
          s.statusRaw.toLowerCase() == _statusFilter!.toLowerCase();

      return matchesQuery && matchesStatus;
    }).toList();
  }

  ServerModel? get currentServer {
    if (_currentDetailId == null) return null;
    try {
      return allServers.firstWhere((s) => s.id == _currentDetailId);
    } catch (_) {
      return null;
    }
  }

  ServerProvider(this._serverRepository) {
    _serverRepository.serversListenable.addListener(_onServersUpdated);
  }

  void _onServersUpdated() {
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void selectServerForDetail(String serverId) {
    _currentDetailId = serverId;
    _actionSuccess = null;
    _actionError = null;
    notifyListeners();
  }

  Future<bool> createServer({
    required String name,
    required String ipAddress,
    String os = '',
    String location = '',
  }) async {
    _isCreating = true;
    _createSuccess = false;
    _createError = null;
    notifyListeners();

    final result = await _serverRepository.createServer(
      CreateServerRequest(
        name: name,
        ipAddress: ipAddress,
        os: os,
        location: location,
      ),
    );

    _isCreating = false;
    if (result.isSuccess) {
      _createSuccess = true;
      notifyListeners();
      return true;
    } else {
      _createError = result.error ?? 'Erreur lors de la création du serveur';
      notifyListeners();
      return false;
    }
  }

  void resetCreateState() {
    _isCreating = false;
    _createSuccess = false;
    _createError = null;
    notifyListeners();
  }

  Future<void> restartServer(String serverId) async {
    _isActionLoading = true;
    _actionSuccess = null;
    _actionError = null;
    notifyListeners();

    await _serverRepository.updateServerStatus(serverId, 'restarting');
    await Future.delayed(const Duration(milliseconds: 2000));
    await _serverRepository.updateServerStatus(serverId, 'online');

    _isActionLoading = false;
    _actionSuccess = 'Serveur redémarré avec succès';
    notifyListeners();
  }

  Future<void> stopServer(String serverId) async {
    _isActionLoading = true;
    _actionSuccess = null;
    _actionError = null;
    notifyListeners();

    await _serverRepository.updateServerStatus(serverId, 'stopping');
    await Future.delayed(const Duration(milliseconds: 1800));
    await _serverRepository.updateServerStatus(serverId, 'stopped');

    _isActionLoading = false;
    _actionSuccess = 'Serveur arrêté';
    notifyListeners();
  }

  Future<bool> deleteServer(String serverId) async {
    _isActionLoading = true;
    _actionSuccess = null;
    _actionError = null;
    notifyListeners();

    final result = await _serverRepository.deleteServer(serverId);
    _isActionLoading = false;
    if (result.isSuccess) {
      if (_currentDetailId == serverId) {
        _currentDetailId = null;
      }
      notifyListeners();
      return true;
    } else {
      _actionError = result.error ?? 'Erreur de suppression';
      notifyListeners();
      return false;
    }
  }

  void clearDetailMessages() {
    _actionSuccess = null;
    _actionError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _serverRepository.serversListenable.removeListener(_onServersUpdated);
    super.dispose();
  }
}
