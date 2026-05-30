import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<void> saveSession(String token, AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode({
      'id': user.id,
      'fullName': user.fullName,
      'email': user.email,
      'phone': user.phone,
      'gender': user.gender,
      'role': user.role,
      'avatarUrl': user.avatarUrl,
      'bio': user.bio,
      'createdAt': user.createdAt,
    }));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<AppUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> saveUser(AppUser user) async {
    final token = await getToken();
    if (token != null) {
      await saveSession(token, user);
    }
  }
}
