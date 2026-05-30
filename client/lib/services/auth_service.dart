import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  AuthService({ApiClient? api, StorageService? storage})
      : _api = api ?? ApiClient(),
        _storage = storage ?? StorageService();

  final ApiClient _api;
  final StorageService _storage;

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String gender,
    required String role,
  }) async {
    final data = await _api.post('/auth/register', body: {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'gender': gender,
      'role': role,
    }) as Map<String, dynamic>;

    final token = data['token'] as String;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    await _storage.saveSession(token, user);
    return user;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    final token = data['token'] as String;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    await _storage.saveSession(token, user);
    return user;
  }

  Future<void> logout() => _storage.clearSession();

  Future<AppUser?> getCurrentUser() => _storage.getUser();

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }
}
