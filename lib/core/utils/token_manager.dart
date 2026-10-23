import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _keyToken = 'auth_token';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRole = 'user_role';

  final SharedPreferences _prefs;

  TokenManager(this._prefs);

  static Future<TokenManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenManager(prefs);
  }

  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<bool> clearToken() async {
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserRole);
    return await _prefs.remove(_keyToken);
  }

  bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  String bearerToken() {
    final token = getToken() ?? '';
    return 'Bearer $token';
  }

  Future<void> saveUserInfo({
    required String email,
    required String name,
    required String role,
  }) async {
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserRole, role);
  }

  String? getUserEmail() => _prefs.getString(_keyUserEmail);
  String? getUserName() => _prefs.getString(_keyUserName);
  String? getUserRole() => _prefs.getString(_keyUserRole);
}
