import 'package:flutter/foundation.dart';

import '../core/network/api_service.dart';
import '../data/mock/mock_data_store.dart';
import '../data/models/api_models.dart';

abstract class ServerRepository {
  ValueListenable<List<ServerModel>> get serversListenable;
  Future<ApiResult<ServerModel>> createServer(CreateServerRequest request);
  Future<ApiResult<void>> deleteServer(String id);
  Future<ApiResult<void>> updateServerStatus(String id, String status);
}

class ServerRepositoryImpl implements ServerRepository {
  final ApiService apiService;
  final MockDataStore mockDataStore;

  ServerRepositoryImpl({required this.apiService, required this.mockDataStore});

  @override
  ValueListenable<List<ServerModel>> get serversListenable =>
      mockDataStore.servers;

  @override
  Future<ApiResult<ServerModel>> createServer(
    CreateServerRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newServer = mockDataStore.addServer(request);
    return ApiResult.success(newServer);
  }

  @override
  Future<ApiResult<void>> deleteServer(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    mockDataStore.deleteServer(id);
    return ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> updateServerStatus(String id, String status) async {
    await Future.delayed(const Duration(milliseconds: 600));
    mockDataStore.updateServerStatus(id, status);
    return ApiResult.success(null);
  }
}
