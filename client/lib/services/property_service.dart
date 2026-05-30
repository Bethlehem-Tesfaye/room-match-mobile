import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/property.dart';
import '../utils/multipart_image.dart';
import 'api_client.dart';

class PropertyQuery {
  const PropertyQuery({
    this.search,
    this.maxBudget,
    this.propertyType,
    this.bedrooms,
    this.ownerId,
    this.verifiedOnly = false,
  });

  final String? search;
  final double? maxBudget;
  final String? propertyType;
  final int? bedrooms;
  final String? ownerId;
  final bool verifiedOnly;

  Map<String, String> toParams() {
    final params = <String, String>{};
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    if (maxBudget != null) params['maxBudget'] = maxBudget!.toString();
    if (propertyType != null && propertyType!.isNotEmpty) {
      params['propertyType'] = propertyType!;
    }
    if (bedrooms != null) params['bedrooms'] = bedrooms!.toString();
    if (ownerId != null) params['ownerId'] = ownerId!;
    if (verifiedOnly) params['verified'] = 'true';
    return params;
  }
}

class PropertyService {
  PropertyService({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Future<List<Property>> fetchProperties([PropertyQuery? query]) async {
    final data = await _api.get(
      '/properties',
      query: query?.toParams(),
    ) as List<dynamic>;
    return data
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Property> getProperty(String id) async {
    final data = await _api.get('/properties/$id') as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  Future<Property> createProperty({
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
    final fields = {
      'title': title,
      'rentAmount': rentAmount.toString(),
      'propertyType': propertyType,
      'bedrooms': bedrooms.toString(),
      'location': location,
      'address': address,
      'phone': phone,
      'email': email,
      'amenities': amenities.join(','),
      'availabilityDate': availabilityDate,
      'leaseLength': leaseLength,
    };

    final files = <http.MultipartFile>[];
    for (var i = 0; i < images.length; i++) {
      files.add(
        await multipartImageFile(
          field: 'images',
          image: images[i],
          index: i,
        ),
      );
    }

    final data = await _api.multipart(
      'POST',
      '/properties',
      fields: fields,
      files: files.isEmpty ? null : files,
    ) as Map<String, dynamic>;

    return Property.fromJson(data);
  }

  Future<Property> updateProperty({
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
    final fields = {
      'title': title,
      'rentAmount': rentAmount.toString(),
      'propertyType': propertyType,
      'bedrooms': bedrooms.toString(),
      'location': location,
      'address': address,
      'phone': phone,
      'email': email,
      'amenities': amenities.join(','),
      'availabilityDate': availabilityDate,
      'leaseLength': leaseLength,
    };

    final files = <http.MultipartFile>[];
    for (var i = 0; i < newImages.length; i++) {
      files.add(
        await multipartImageFile(
          field: 'images',
          image: newImages[i],
          index: i,
        ),
      );
    }

    final data = await _api.multipart(
      'PUT',
      '/properties/$id',
      fields: fields,
      files: files.isEmpty ? null : files,
    ) as Map<String, dynamic>;

    return Property.fromJson(data);
  }

  Future<void> deleteProperty(String id) async {
    await _api.delete('/properties/$id');
  }
}
