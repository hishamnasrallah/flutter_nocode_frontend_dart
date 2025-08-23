// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  late final AuthRepository _authRepository;

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  AuthProvider(this._apiService, this._storageService) {
    _authRepository = AuthRepository(_apiService, _storageService);
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    debugPrint('Checking auth status...');
    _isLoading = true;
    notifyListeners();

    try {
      final hasTokens = await _storageService.hasTokens();
      debugPrint('Has tokens: $hasTokens');

      if (hasTokens) {
        final userData = await _storageService.getUser();
        debugPrint('User data: $userData');

        if (userData != null) {
          _user = User.fromJson(userData);
          _isAuthenticated = true;
          debugPrint('User authenticated: ${_user?.username}');

          // Try to refresh user data
          try {
            _user = await _authRepository.getCurrentUser();
            debugPrint('User data refreshed');
          } catch (e) {
            debugPrint('Failed to refresh user data: $e');
            // Use cached user data if refresh fails
          }
        }
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      debugPrint('Auth initialized - authenticated: $_isAuthenticated');
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    debugPrint('Attempting login for: $username');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(username, password);
      _isAuthenticated = true;
      debugPrint('Login successful: ${_user?.username}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      _error = e.toString();
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    debugPrint('Logging out...');
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
      // Ignore logout errors
    } finally {
      _user = null;
      _isAuthenticated = false;
      _error = null;
      _isLoading = false;
      debugPrint('Logged out successfully');
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.changePassword(oldPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}