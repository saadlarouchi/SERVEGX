import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool get isAuthenticated => _authRepository.isLoggedIn();

  AuthProvider(this._authRepository);

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    final result = await _authRepository.login(email, password);

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _isSuccess = true;
      _token = result.data!.resolvedToken;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error ?? 'Échec de connexion';
      _isSuccess = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    final result = await _authRepository.register(email, password, name);

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _isSuccess = true;
      _token = result.data!.resolvedToken;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error ?? 'Échec de création de compte';
      _isSuccess = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _isSuccess = false;
    _token = null;
    _errorMessage = null;
    notifyListeners();
  }

  void resetState() {
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }
}
