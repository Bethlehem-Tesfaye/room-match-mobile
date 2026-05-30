import '../models/property.dart';
import 'api_client.dart';

class FavoriteService {
  FavoriteService({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Future<List<Property>> getFavorites(String userId) async {
    final data = await _api.get('/favorites/$userId') as List<dynamic>;
    return data
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Property> addFavorite({
    required String userId,
    required String propertyId,
  }) async {
    final data = await _api.post('/favorites', body: {
      'userId': userId,
      'propertyId': propertyId,
    }) as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  Future<void> removeFavorite({
    required String userId,
    required String propertyId,
  }) async {
    await _api.delete('/favorites/$userId/$propertyId');
  }
}
