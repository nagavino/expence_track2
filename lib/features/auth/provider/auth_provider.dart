import 'package:flutter/foundation.dart';
import '../../../core/storage/local_database_service.dart';
import '../../../core/storage/token_storage.dart';
import '../model/user_model.dart';

/// Authentication state enum
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Provider for managing authentication state offline
class AuthProvider extends ChangeNotifier {
  final LocalDatabaseService _dbService;
  final TokenStorage _tokenStorage;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider({
    LocalDatabaseService? dbService,
    TokenStorage? tokenStorage,
  })  : _dbService = dbService ?? LocalDatabaseService(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  // ============ Getters ============

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isAdmin => _user?.isAdmin ?? false;

  // ============ Auth Methods ============

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final isLoggedIn = await _tokenStorage.isLoggedIn();

      if (isLoggedIn) {
        final userId = await _tokenStorage.getUserId();
        final userName = await _tokenStorage.getUserName();
        final userEmail = await _tokenStorage.getUserEmail();
        final userRole = await _tokenStorage.getUserRole();

        if (userId != null && userName != null && userEmail != null) {
          _user = User(
            id: userId,
            name: userName,
            email: userEmail,
            role: userRole ?? 'USER',
          );
          _state = AuthState.authenticated;
        } else {
          _state = AuthState.unauthenticated;
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
    }

    notifyListeners();
  }

  /// Login locally with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _dbService.loginUser(
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        final user = result.user!;
        final token = result.token ?? 'local_token_${user.id}';

        await _tokenStorage.saveToken(token);
        await _tokenStorage.saveUserData(
          userId: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        );

        _user = user;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message;
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred during login';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Register new user locally
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _dbService.registerUser(
        name: name,
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        final user = result.user!;
        final token = result.token ?? 'local_token_${user.id}';

        await _tokenStorage.saveToken(token);
        await _tokenStorage.saveUserData(
          userId: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        );

        _user = user;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message;
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred during registration';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Logout user locally
  Future<void> logout() async {
    await _tokenStorage.clear();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
