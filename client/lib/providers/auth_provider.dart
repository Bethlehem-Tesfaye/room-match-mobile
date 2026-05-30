import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    UserService? userService,
  })  : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService();

  final AuthService _authService;
  final UserService _userService;

  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  String? errorMessage;

  /// True only while checking stored session on app start.
  bool isInitializing = false;

  /// True during login, register, or profile update.
  bool isSubmitting = false;

  Future<void> init() async {
    isInitializing = true;
    notifyListeners();
    try {
      final current = await _authService.getCurrentUser();
      if (current != null) {
        user = await _userService.getUser(current.id);
        status = AuthStatus.authenticated;
      } else {
        status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      await _authService.logout();
      status = AuthStatus.unauthenticated;
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    return _runAuth(() => _authService.login(email: email, password: password));
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String gender,
    required String role,
  }) async {
    return _runAuth(
      () => _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        gender: gender,
        role: role,
      ),
    );
  }

  Future<bool> _runAuth(Future<AppUser> Function() action) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      user = await action();
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = AuthStatus.unauthenticated;
      return false;
    } catch (_) {
      errorMessage = 'Network error. Is the server running?';
      status = AuthStatus.unauthenticated;
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String bio,
    XFile? avatar,
  }) async {
    if (user == null) return false;
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      user = await _userService.updateProfile(
        userId: user!.id,
        fullName: fullName,
        email: email,
        phone: phone,
        bio: bio,
        avatar: avatar,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'Failed to update profile';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
