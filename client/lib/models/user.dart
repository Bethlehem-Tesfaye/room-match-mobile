class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.role,
    required this.avatarUrl,
    required this.bio,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String role;
  final String avatarUrl;
  final String bio;
  final String? createdAt;

  bool get isOwner => role == 'owner';

  String get firstName {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : 'there';
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Male',
      role: json['role'] as String? ?? 'tenant',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'bio': bio,
      'gender': gender,
    };
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt,
    );
  }
}
