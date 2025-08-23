// lib/data/repositories/auth_repository.dart
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import '../../core/constants/api_endpoints.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository(this._apiService, this._storageService);

  Future<User> login(String username, String password) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = response.data;
    await _storageService.saveTokens(
      accessToken: data['tokens']['access'],
      refreshToken: data['tokens']['refresh'],
    );

    final user = User.fromJson(data['user']);
    await _storageService.saveUser(data['user']);

    return user;
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName ?? '',
        'last_name': lastName ?? '',
      },
    );

    final data = response.data;
    await _storageService.saveTokens(
      accessToken: data['tokens']['access'],
      refreshToken: data['tokens']['refresh'],
    );

    final user = User.fromJson(data['user']);
    await _storageService.saveUser(data['user']);

    return user;
  }

  Future<void> logout() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _apiService.post(
          ApiEndpoints.logout,
          data: {'refresh': refreshToken},
        );
      } catch (e) {
        // Ignore logout errors
      }
    }

    await _storageService.clearTokens();
    await _storageService.clearUser();
  }

  Future<User> getCurrentUser() async {
    final response = await _apiService.get(ApiEndpoints.me);
    final user = User.fromJson(response.data['user']);
    await _storageService.saveUser(response.data['user']);
    return user;
  }

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final response = await _apiService.put(
      ApiEndpoints.updateProfile,
      data: {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
      },
    );

    final user = User.fromJson(response.data['user']);
    await _storageService.saveUser(response.data['user']);
    return user;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _apiService.post(
      ApiEndpoints.changePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<void> forgotPassword(String email) async {
    await _apiService.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _apiService.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'new_password': newPassword,
      },
    );
  }
}