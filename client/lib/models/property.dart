import '../config/api_config.dart';

class PropertyOwner {
  const PropertyOwner({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl = '',
    this.bio = '',
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String bio;

  factory PropertyOwner.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PropertyOwner(
        id: '',
        fullName: 'Owner',
        email: '',
        phone: '',
      );
    }
    return PropertyOwner(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Owner',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
    );
  }
}

class Property {
  const Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.rentAmount,
    required this.propertyType,
    required this.bedrooms,
    required this.location,
    required this.address,
    required this.phone,
    required this.email,
    required this.amenities,
    required this.availabilityDate,
    required this.leaseLength,
    required this.images,
    required this.verified,
    this.createdAt,
    this.owner,
  });

  final String id;
  final String ownerId;
  final String title;
  final num rentAmount;
  final String propertyType;
  final int bedrooms;
  final String location;
  final String address;
  final String phone;
  final String email;
  final List<String> amenities;
  final String availabilityDate;
  final String leaseLength;
  final List<String> images;
  final bool verified;
  final String? createdAt;
  final PropertyOwner? owner;

  String get displayImage {
    if (images.isEmpty) {
      return 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80';
    }
    return ApiConfig.resolveUrl(images.first);
  }

  List<String> get resolvedImages {
    if (images.isEmpty) return [displayImage];
    return images.map(ApiConfig.resolveUrl).toList();
  }

  String get formattedPrice => 'ETB ${rentAmount.toStringAsFixed(0)} / mo';

  String get bedroomLabel =>
      bedrooms >= 4 ? '3+ bedrooms' : '$bedrooms bedroom${bedrooms == 1 ? '' : 's'}';

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      rentAmount: json['rentAmount'] as num? ?? 0,
      propertyType: json['propertyType'] as String? ?? 'Apartment',
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 1,
      location: json['location'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      availabilityDate: json['availabilityDate'] as String? ?? '',
      leaseLength: json['leaseLength'] as String? ?? '12 Months',
      images: List<String>.from(json['images'] as List? ?? []),
      verified: json['verified'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      owner: json['owner'] != null
          ? PropertyOwner.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toFeaturedMap() {
    return {
      'id': id,
      'image': displayImage,
      'price': formattedPrice,
      'title': title,
      'location': location,
      'details': '$propertyType · $bedroomLabel',
      'propertyType': propertyType,
      'rentAmount': rentAmount,
      'bedrooms': bedrooms,
      'verified': verified,
    };
  }

  Map<String, dynamic> toRecentMap() {
    final amenitySnippet = amenities.isEmpty
        ? 'Available from ${_formatDate(availabilityDate)}.'
        : '${amenities.take(2).join(', ')}. Available from ${_formatDate(availabilityDate)}.';

    return {
      'id': id,
      'image': displayImage,
      'title': title,
      'price': formattedPrice,
      'snippet': amenitySnippet,
      'location': location,
      'distance': propertyType,
      'roommates': bedroomLabel,
      'address': address,
      'propertyType': propertyType,
      'rentAmount': rentAmount,
      'bedrooms': bedrooms,
    };
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'soon';
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
