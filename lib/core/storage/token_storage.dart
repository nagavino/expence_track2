import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure Local Storage service for managing local session and auth credentials offline
class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  SharedPreferences? _prefs;

  /// Initialize storage instances
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  /// Save local session token
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (_) {}
    final prefs = await _preferences;
    await prefs.setString(_tokenKey, token);
  }

  /// Get stored authentication token
  Future<String?> getToken() async {
    try {
      final secureToken = await _secureStorage.read(key: _tokenKey);
      if (secureToken != null && secureToken.isNotEmpty) return secureToken;
    } catch (_) {}
    final prefs = await _preferences;
    return prefs.getString(_tokenKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user data after local login/registration
  Future<void> saveUserData({
    required int userId,
    required String name,
    required String email,
    required String role,
  }) async {
    final prefs = await _preferences;
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);

    try {
      await _secureStorage.write(key: _userIdKey, value: userId.toString());
      await _secureStorage.write(key: _userNameKey, value: name);
      await _secureStorage.write(key: _userEmailKey, value: email);
      await _secureStorage.write(key: _userRoleKey, value: role);
    } catch (_) {}
  }

  /// Get stored user ID
  Future<int?> getUserId() async {
    final prefs = await _preferences;
    final id = prefs.getInt(_userIdKey);
    if (id != null) return id;

    try {
      final secId = await _secureStorage.read(key: _userIdKey);
      if (secId != null) return int.tryParse(secId);
    } catch (_) {}
    return null;
  }

  /// Get stored user name
  Future<String?> getUserName() async {
    final prefs = await _preferences;
    final name = prefs.getString(_userNameKey);
    if (name != null) return name;

    try {
      return await _secureStorage.read(key: _userNameKey);
    } catch (_) {}
    return null;
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    final prefs = await _preferences;
    final email = prefs.getString(_userEmailKey);
    if (email != null) return email;

    try {
      return await _secureStorage.read(key: _userEmailKey);
    } catch (_) {}
    return null;
  }

  /// Get stored user role
  Future<String?> getUserRole() async {
    final prefs = await _preferences;
    final role = prefs.getString(_userRoleKey);
    if (role != null) return role;

    try {
      return await _secureStorage.read(key: _userRoleKey);
    } catch (_) {}
    return null;
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role?.toUpperCase() == 'ADMIN';
  }

  /// Clear all stored session data (logout)
  Future<void> clear() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    final prefs = await _preferences;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
  }
}
