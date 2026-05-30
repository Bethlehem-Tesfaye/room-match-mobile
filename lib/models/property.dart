import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  const Property({
    this.id,
    required this.title,
    required this.rent,
    required this.address,
    required this.propertyType,
    required this.bedrooms,
    required this.amenities,
    required this.availableDate,
    required this.leaseLength,
    required this.phone,
    required this.email,
    this.imageUrls = const [],
    this.createdAt,
  });

  final String? id;
  final String title;
  final double rent;
  final String address;
  final String propertyType;
  final int bedrooms;
  final List<String> amenities;
  final DateTime availableDate;
  final String leaseLength;
  final String phone;
  final String email;
  final List<String> imageUrls;
  final DateTime? createdAt;

  static const _defaultImage =
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80';

  String get displayImage => imageUrls.isNotEmpty ? imageUrls.first : _defaultImage;

  String get formattedPrice => 'ETB ${rent.toStringAsFixed(0)} / mo';

  String get bedroomLabel => bedrooms >= 4 ? '3+ bedrooms' : '$bedrooms bedroom${bedrooms == 1 ? '' : 's'}';

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'rent': rent,
      'address': address,
      'propertyType': propertyType,
      'bedrooms': bedrooms,
      'amenities': amenities,
      'availableDate': Timestamp.fromDate(availableDate),
      'leaseLength': leaseLength,
      'phone': phone,
      'email': email,
      'imageUrls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Property.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Property(
      id: doc.id,
      title: data['title'] as String? ?? '',
      rent: (data['rent'] as num?)?.toDouble() ?? 0,
      address: data['address'] as String? ?? '',
      propertyType: data['propertyType'] as String? ?? 'Apartment',
      bedrooms: (data['bedrooms'] as num?)?.toInt() ?? 1,
      amenities: List<String>.from(data['amenities'] as List? ?? []),
      availableDate: (data['availableDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      leaseLength: data['leaseLength'] as String? ?? '12 Months',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFeaturedMap() {
    return {
      'image': displayImage,
      'price': formattedPrice,
      'title': title,
      'location': address,
      'details': '$propertyType · $bedroomLabel',
      'propertyType': propertyType,
      'rentAmount': rent,
      'tags': _buildTags(),
    };
  }

  Map<String, dynamic> toRecentMap() {
    final amenitySnippet = amenities.isEmpty
        ? 'Available from ${_formatDate(availableDate)}.'
        : '${amenities.take(2).join(', ')}. Available from ${_formatDate(availableDate)}.';

    return {
      'image': displayImage,
      'title': title,
      'price': formattedPrice,
      'snippet': amenitySnippet,
      'location': address.split(',').first.trim(),
      'distance': propertyType,
      'roommates': bedroomLabel,
      'address': address,
      'propertyType': propertyType,
      'rentAmount': rent,
      'tags': _buildTags(),
    };
  }

  List<String> _buildTags() {
    final tags = <String>[];
    if (address.isNotEmpty) tags.add('Location');
    if (rent > 0) tags.add('Budget');
    tags.add('Room type');
    return tags;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
