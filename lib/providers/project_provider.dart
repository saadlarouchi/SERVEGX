import 'package:flutter/foundation.dart';

import '../data/models/api_models.dart';
import '../repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepository _projectRepository;

  final bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  final Set<String> _loadingProjectIds = {};

  // Create state
  bool _isCreating = false;
  bool _createSuccess = false;
  String? _createError;
  List<ServerDropdownItem> _dropdownServers = [];
  bool _serversLoading = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  Set<String> get loadingProjectIds => _loadingProjectIds;

  bool get isCreating => _isCreating;
  bool get createSuccess => _createSuccess;
  String? get createError => _createError;
  List<ServerDropdownItem> get dropdownServers => _dropdownServers;
  bool get serversLoading => _serversLoading;

  List<ProjectModel> get allProjects =>
      _projectRepository.projectsListenable.value;

  List<ProjectModel> get filteredProjects {
    if (_searchQuery.isEmpty) return allProjects;
    return allProjects.where((p) {
      final nameMatches = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final descMatches =
          p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false;
      final serverMatches =
          p.serverName?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false;
      return nameMatches || descMatches || serverMatches;
    }).toList();
  }

  ProjectProvider(this._projectRepository) {
    _projectRepository.projectsListenable.addListener(_onProjectsUpdated);
  }

  void _onProjectsUpdated() {
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isProjectLoading(String id) => _loadingProjectIds.contains(id);

  Future<void> deployProject(String id) async {
    _loadingProjectIds.add(id);
    notifyListeners();

    await _projectRepository.deployProject(id);

    _loadingProjectIds.remove(id);
    notifyListeners();
  }

  Future<void> restartProject(String id) async {
    _loadingProjectIds.add(id);
    notifyListeners();

    await _projectRepository.restartProject(id);

    _loadingProjectIds.remove(id);
    notifyListeners();
  }

  Future<void> stopProject(String id) async {
    _loadingProjectIds.add(id);
    notifyListeners();

    await _projectRepository.stopProject(id);

    _loadingProjectIds.remove(id);
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _loadingProjectIds.add(id);
    notifyListeners();

    await _projectRepository.deleteProject(id);

    _loadingProjectIds.remove(id);
    notifyListeners();
  }

  Future<void> loadServersForDropdown() async {
    _serversLoading = true;
    notifyListeners();

    _dropdownServers = await _projectRepository.getServersForDropdown();
    _serversLoading = false;
    notifyListeners();
  }

  Future<bool> createProject({
    required String name,
    String? description,
    String? serverId,
  }) async {
    _isCreating = true;
    _createSuccess = false;
    _createError = null;
    notifyListeners();

    final result = await _projectRepository.createProject(
      CreateProjectRequest(
        name: name,
        description: description,
        serverId: serverId,
      ),
    );

    _isCreating = false;
    if (result.isSuccess) {
      _createSuccess = true;
      notifyListeners();
      return true;
    } else {
      _createError = result.error ?? 'Erreur lors de la création du projet';
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

  @override
  void dispose() {
    _projectRepository.projectsListenable.removeListener(_onProjectsUpdated);
    super.dispose();
  }
}
