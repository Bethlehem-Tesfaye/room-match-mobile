import 'property.dart';

class Favorite {
  const Favorite({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.createdAt,
    this.property,
  });

  final String id;
  final String userId;
  final String propertyId;
  final String createdAt;
  final Property? property;

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      property: json['property'] != null
          ? Property.fromJson(json['property'] as Map<String, dynamic>)
          : null,
    );
  }
}
