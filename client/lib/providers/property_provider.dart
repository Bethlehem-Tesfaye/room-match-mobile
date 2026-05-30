import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/property.dart';
import '../services/api_client.dart';
import '../services/property_service.dart';

class PropertyProvider extends ChangeNotifier {
  PropertyProvider({PropertyService? propertyService})
      : _propertyService = propertyService ?? PropertyService();

  final PropertyService _propertyService;

  List<Property> allProperties = [];
  List<Property> myProperties = [];
  Property? selectedProperty;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  List<Property> get featuredListings {
    final verified = allProperties.where((p) => p.verified).toList();
    final source = verified.isNotEmpty ? verified : allProperties;
    return source.take(6).toList();
  }

  List<Property> get recentListings => allProperties;

  Future<void> loadProperties({
    String? search,
    double? maxBudget,
    String? propertyType,
    int? bedrooms,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      allProperties = await _propertyService.fetchProperties(
        PropertyQuery(
          search: search,
          maxBudget: maxBudget,
          propertyType: propertyType,
          bedrooms: bedrooms,
        ),
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      allProperties = [];
    } catch (_) {
      errorMessage = 'Could not load listings. Check your connection.';
      allProperties = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Property?> loadPropertyDetails(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedProperty = await _propertyService.getProperty(id);
      return selectedProperty;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (_) {
      errorMessage = 'Could not load property details';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyProperties(String ownerId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      myProperties = await _propertyService.fetchProperties(
        PropertyQuery(ownerId: ownerId),
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      myProperties = [];
    } catch (_) {
      errorMessage = 'Could not load your properties';
      myProperties = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProperty(String id) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _propertyService.deleteProperty(id);
      myProperties.removeWhere((p) => p.id == id);
      allProperties.removeWhere((p) => p.id == id);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'Failed to delete property';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateProperty({
    required String id,
    required String title,
    required double rentAmount,
    required String propertyType,
    required int bedrooms,
    required String location,
    required String address,
    required String phone,
    required String email,
    required List<String> amenities,
    required String availabilityDate,
    required String leaseLength,
    List<XFile> newImages = const [],
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await _propertyService.updateProperty(
        id: id,
        title: title,
        rentAmount: rentAmount,
        propertyType: propertyType,
        bedrooms: bedrooms,
        location: location,
        address: address,
        phone: phone,
        email: email,
        amenities: amenities,
        availabilityDate: availabilityDate,
        leaseLength: leaseLength,
        newImages: newImages,
      );

      final myIndex = myProperties.indexWhere((p) => p.id == id);
      if (myIndex >= 0) myProperties[myIndex] = updated;

      final allIndex = allProperties.indexWhere((p) => p.id == id);
      if (allIndex >= 0) allProperties[allIndex] = updated;

      if (selectedProperty?.id == id) selectedProperty = updated;

      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'Failed to update property';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> createProperty({
    required String title,
    required double rentAmount,
    required String propertyType,
    required int bedrooms,
    required String location,
    required String address,
    required String phone,
    required String email,
    required List<String> amenities,
    required String availabilityDate,
    required String leaseLength,
    required List<XFile> images,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final created = await _propertyService.createProperty(
        title: title,
        rentAmount: rentAmount,
        propertyType: propertyType,
        bedrooms: bedrooms,
        location: location,
        address: address,
        phone: phone,
        email: email,
        amenities: amenities,
        availabilityDate: availabilityDate,
        leaseLength: leaseLength,
        images: images,
      );
      allProperties.insert(0, created);
      myProperties.insert(0, created);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'Failed to publish listing';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
