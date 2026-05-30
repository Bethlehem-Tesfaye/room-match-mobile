import 'package:flutter/foundation.dart';

import '../models/property.dart';
import '../services/api_client.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider({FavoriteService? favoriteService})
      : _favoriteService = favoriteService ?? FavoriteService();

  final FavoriteService _favoriteService;

  final Set<String> _favoriteIds = {};
  List<Property> favoriteProperties = [];
  String? _userId;
  bool isLoading = false;
  String? errorMessage;

  bool get hasUser => _userId != null;

  bool isFavorite(String propertyId) => _favoriteIds.contains(propertyId);

  Future<void> loadFavorites(String userId) async {
    if (_userId == userId && favoriteProperties.isNotEmpty && !isLoading) {
      return;
    }

    _userId = userId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      favoriteProperties = await _favoriteService.getFavorites(userId);
      _favoriteIds
        ..clear()
        ..addAll(favoriteProperties.map((p) => p.id));
    } on ApiException catch (e) {
      errorMessage = e.message;
      favoriteProperties = [];
      _favoriteIds.clear();
    } catch (_) {
      errorMessage = 'Could not load favorites';
      favoriteProperties = [];
      _favoriteIds.clear();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _userId = null;
    _favoriteIds.clear();
    favoriteProperties = [];
    errorMessage = null;
    notifyListeners();
  }

  Future<void> toggleFavorite(String propertyId, {Property? property}) async {
    if (_userId == null) return;

    final wasFavorite = isFavorite(propertyId);

    if (wasFavorite) {
      _favoriteIds.remove(propertyId);
      favoriteProperties.removeWhere((p) => p.id == propertyId);
    } else {
      _favoriteIds.add(propertyId);
      if (property != null && !favoriteProperties.any((p) => p.id == propertyId)) {
        favoriteProperties.insert(0, property);
      }
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await _favoriteService.removeFavorite(
          userId: _userId!,
          propertyId: propertyId,
        );
      } else {
        final saved = await _favoriteService.addFavorite(
          userId: _userId!,
          propertyId: propertyId,
        );
        final index = favoriteProperties.indexWhere((p) => p.id == propertyId);
        if (index >= 0) {
          favoriteProperties[index] = saved;
        } else {
          favoriteProperties.insert(0, saved);
        }
        notifyListeners();
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
      _revertToggle(propertyId, wasFavorite, property);
    } catch (_) {
      errorMessage = 'Could not update favorite';
      _revertToggle(propertyId, wasFavorite, property);
    }
    notifyListeners();
  }

  void _revertToggle(String propertyId, bool wasFavorite, Property? property) {
    if (wasFavorite) {
      _favoriteIds.add(propertyId);
      if (property != null && !favoriteProperties.any((p) => p.id == propertyId)) {
        favoriteProperties.insert(0, property);
      }
    } else {
      _favoriteIds.remove(propertyId);
      favoriteProperties.removeWhere((p) => p.id == propertyId);
    }
  }

  Property? findPropertyInCache(String propertyId) {
    try {
      return favoriteProperties.firstWhere((p) => p.id == propertyId);
    } catch (_) {
      return null;
    }
  }
}
