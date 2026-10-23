import 'package:flutter/foundation.dart';

import '../core/network/api_service.dart';
import '../data/mock/mock_data_store.dart';
import '../data/models/api_models.dart';

abstract class ProjectRepository {
  ValueListenable<List<ProjectModel>> get projectsListenable;
  Future<ApiResult<ProjectModel>> createProject(CreateProjectRequest request);
  Future<ApiResult<void>> deleteProject(String id);
  Future<ApiResult<void>> deployProject(String id);
  Future<ApiResult<void>> restartProject(String id);
  Future<ApiResult<void>> stopProject(String id);
  Future<List<ServerDropdownItem>> getServersForDropdown();
}

class ProjectRepositoryImpl implements ProjectRepository {
  final ApiService apiService;
  final MockDataStore mockDataStore;

  ProjectRepositoryImpl({
    required this.apiService,
    required this.mockDataStore,
  });

  @override
  ValueListenable<List<ProjectModel>> get projectsListenable =>
      mockDataStore.projects;

  @override
  Future<ApiResult<ProjectModel>> createProject(
    CreateProjectRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final project = mockDataStore.addProject(request);
    return ApiResult.success(project);
  }

  @override
  Future<ApiResult<void>> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    mockDataStore.deleteProject(id);
    return ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> deployProject(String id) async {
    await mockDataStore.deployProject(id);
    return ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> restartProject(String id) async {
    await mockDataStore.restartProject(id);
    return ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> stopProject(String id) async {
    await mockDataStore.stopProject(id);
    return ApiResult.success(null);
  }

  @override
  Future<List<ServerDropdownItem>> getServersForDropdown() async {
    return mockDataStore.servers.value
        .map((s) => ServerDropdownItem(id: s.id, name: s.name))
        .toList();
  }
}
