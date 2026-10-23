import '../core/network/api_service.dart';
import '../core/utils/token_manager.dart';
import '../data/mock/mock_data_store.dart';
import '../data/models/api_models.dart';
import '../data/models/notification_models.dart';

abstract class AuthRepository {
  Future<ApiResult<LoginResponse>> login(String email, String password);
  Future<ApiResult<LoginResponse>> register(
    String email,
    String password,
    String name,
  );
  Future<void> logout();
  bool isLoggedIn();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  final TokenManager tokenManager;
  final MockDataStore mockDataStore;

  AuthRepositoryImpl({
    required this.apiService,
    required this.tokenManager,
    required this.mockDataStore,
  });

  @override
  Future<ApiResult<LoginResponse>> login(String email, String password) async {
    // Check mock data store first as Kotlin implementation does
    await Future.delayed(const Duration(milliseconds: 800));
    final pass = mockDataStore.passwords[email];
    if (pass != null && pass == password) {
      final user = mockDataStore.users.firstWhere(
        (u) => u.email == email,
        orElse: () => UserResponse(
          id: '1',
          name: 'Administrateur',
          email: email,
          role: 'admin',
        ),
      );
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await tokenManager.saveToken(token);
      await tokenManager.saveUserInfo(
        email: email,
        name: user.name ?? 'Utilisateur',
        role: user.role ?? 'user',
      );
      mockDataStore.addLog('INFO', 'AUTH', '${user.name} s\'est connecté');
      mockDataStore.pushEvent(UserLoggedInEvent(email: email));

      return ApiResult.success(LoginResponse(accessToken: token, user: user));
    }

    // Try real API fallback if mock doesn't match
    final result = await apiService.login(
      LoginRequest(email: email, password: password),
    );
    if (result.isSuccess && result.data != null) {
      final token = result.data!.resolvedToken;
      if (token != null) {
        await tokenManager.saveToken(token);
        if (result.data!.user != null) {
          await tokenManager.saveUserInfo(
            email: result.data!.user!.email ?? email,
            name: result.data!.user!.name ?? '',
            role: result.data!.user!.role ?? 'user',
          );
        }
      }
    }
    return result;
  }

  @override
  Future<ApiResult<LoginResponse>> register(
    String email,
    String password,
    String name,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mockDataStore.passwords.containsKey(email)) {
      return ApiResult.failure('Cet e-mail est déjà utilisé');
    }

    final newUser = UserResponse(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: 'user',
    );
    mockDataStore.users.add(newUser);
    mockDataStore.passwords[email] = password;

    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await tokenManager.saveToken(token);
    await tokenManager.saveUserInfo(email: email, name: name, role: 'user');
    mockDataStore.addLog('SUCCESS', 'AUTH', '$name s\'est inscrit');
    mockDataStore.pushEvent(UserRegisteredEvent(email: email));

    return ApiResult.success(LoginResponse(accessToken: token, user: newUser));
  }

  @override
  Future<void> logout() async {
    final email = tokenManager.getUserEmail() ?? '';
    await tokenManager.clearToken();
    if (email.isNotEmpty) {
      mockDataStore.addLog('INFO', 'AUTH', '$email s\'est déconnecté');
      mockDataStore.pushEvent(UserLoggedOutEvent(email: email));
    }
  }

  @override
  bool isLoggedIn() => tokenManager.isLoggedIn();
}
