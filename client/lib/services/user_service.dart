import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../utils/multipart_image.dart';
import 'api_client.dart';
import 'storage_service.dart';

class UserService {
  UserService({ApiClient? api, StorageService? storage})
      : _api = api ?? ApiClient(),
        _storage = storage ?? StorageService();

  final ApiClient _api;
  final StorageService _storage;

  Future<AppUser> getUser(String id) async {
    final data = await _api.get('/users/$id') as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  Future<AppUser> updateProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
    required String bio,
    XFile? avatar,
  }) async {
    final fields = {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'bio': bio,
    };

    List<http.MultipartFile>? files;
    if (avatar != null) {
      files = [
        await multipartImageFile(
          field: 'avatar',
          image: avatar,
          index: 0,
        ),
      ];
    }

    final data = await _api.multipart(
      'PUT',
      '/users/$userId',
      fields: fields,
      files: files,
    ) as Map<String, dynamic>;

    final user = AppUser.fromJson(data);
    await _storage.saveUser(user);
    return user;
  }
}
