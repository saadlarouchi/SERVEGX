import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../../data/models/api_models.dart';
import 'api_client.dart';

class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResult.success(this.data) : error = null, isSuccess = true;

  ApiResult.failure(this.error) : data = null, isSuccess = false;
}

class ApiService {
  final ApiClient apiClient;

  ApiService(this.apiClient);

  Future<ApiResult<T>> _safeApiCall<T>(
    Future<Response> Function() call,
    T Function(dynamic data) mapper,
  ) async {
    try {
      final response = await call();
      final statusCode = response.statusCode ?? 200;

      if (statusCode >= 200 && statusCode < 300) {
        if (response.data != null) {
          return ApiResult.success(mapper(response.data));
        } else {
          return ApiResult.failure('Réponse vide du serveur');
        }
      } else if (statusCode == 401) {
        return ApiResult.failure('Non autorisé — reconnectez-vous');
      } else if (statusCode == 403) {
        return ApiResult.failure('Accès refusé');
      } else if (statusCode == 404) {
        return ApiResult.failure('Ressource introuvable');
      } else if (statusCode >= 500) {
        return ApiResult.failure('Erreur serveur ($statusCode)');
      } else {
        String errMsg = 'Erreur $statusCode';
        if (response.data is Map<String, dynamic>) {
          final err = ApiErrorResponse.fromJson(
            response.data as Map<String, dynamic>,
          );
          errMsg = err.resolved;
        }
        return ApiResult.failure(errMsg);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return ApiResult.failure(
          'Serveur inaccessible — vérifiez votre connexion',
        );
      }
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        final err = ApiErrorResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
        );
        return ApiResult.failure(err.resolved);
      }
      return ApiResult.failure('Erreur réseau: ${e.message}');
    } catch (e) {
      return ApiResult.failure('Erreur : $e');
    }
  }

  Future<ApiResult<LoginResponse>> login(LoginRequest request) {
    return _safeApiCall(
      () => apiClient.dio.post(ApiConstants.login, data: request.toJson()),
      (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<DashboardResponse>> getDashboard() {
    return _safeApiCall(
      () => apiClient.dio.get(ApiConstants.dashboard),
      (data) => DashboardResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<MetricsModel>> getServerMetrics() {
    return _safeApiCall(
      () => apiClient.dio.get(ApiConstants.serverMetrics),
      (data) => MetricsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<List<ServerModel>>> getServers() {
    return _safeApiCall(
      () => apiClient.dio.get(ApiConstants.servers),
      (data) => (data as List)
          .map((e) => ServerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResult<ServerModel>> createServer(CreateServerRequest request) {
    return _safeApiCall(
      () => apiClient.dio.post(ApiConstants.servers, data: request.toJson()),
      (data) => ServerModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> deleteServer(String id) {
    return _safeApiCall(
      () => apiClient.dio.delete('${ApiConstants.servers}/$id'),
      (_) {},
    );
  }

  Future<ApiResult<List<ProjectModel>>> getProjects() {
    return _safeApiCall(
      () => apiClient.dio.get(ApiConstants.projects),
      (data) => (data as List)
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResult<ProjectModel>> createProject(CreateProjectRequest request) {
    return _safeApiCall(
      () => apiClient.dio.post(ApiConstants.projects, data: request.toJson()),
      (data) => ProjectModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> deleteProject(String id) {
    return _safeApiCall(
      () => apiClient.dio.delete('${ApiConstants.projects}/$id'),
      (_) {},
    );
  }

  Future<ApiResult<List<AlertModel>>> getAlerts() {
    return _safeApiCall(
      () => apiClient.dio.get(ApiConstants.alerts),
      (data) => (data as List)
          .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResult<List<LogModel>>> getLogs() {
    return _safeApiCall(
      () => apiClient.dio.get(ApiConstants.logs),
      (data) => (data as List)
          .map((e) => LogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResult<List<UserResponse>>> getUsers() {
    return _safeApiCall(
      () => apiClient.dio.get(ApiConstants.users),
      (data) => (data as List)
          .map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
