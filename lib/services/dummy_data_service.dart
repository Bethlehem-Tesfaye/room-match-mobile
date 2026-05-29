import 'dart:convert';

import 'package:flutter/services.dart';

class DummyHomeData {
  const DummyHomeData({
    required this.filterChips,
    required this.roomTypeOptions,
    required this.greetingName,
    required this.roomsNearText,
    required this.headerAvatarUrl,
    required this.featuredListings,
    required this.recentListings,
  });

  final List<String> filterChips;
  final List<String> roomTypeOptions;
  final String greetingName;
  final String roomsNearText;
  final String headerAvatarUrl;
  final List<Map<String, dynamic>> featuredListings;
  final List<Map<String, dynamic>> recentListings;

  factory DummyHomeData.fromJson(Map<String, dynamic> json) {
    return DummyHomeData(
      filterChips: List<String>.from(json['filterChips'] as List),
      roomTypeOptions: List<String>.from(json['roomTypeOptions'] as List),
      greetingName: json['greetingName'] as String,
      roomsNearText: json['roomsNearText'] as String,
      headerAvatarUrl: json['headerAvatarUrl'] as String,
      featuredListings: (json['featuredListings'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      recentListings: (json['recentListings'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }
}

class DummyProfileData {
  const DummyProfileData({
    required this.avatarUrl,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.hints,
  });

  final String avatarUrl;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final Map<String, String> hints;

  factory DummyProfileData.fromJson(Map<String, dynamic> json) {
    final hintsJson = json['hints'] as Map<String, dynamic>;
    return DummyProfileData(
      avatarUrl: json['avatarUrl'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      bio: json['bio'] as String,
      hints: hintsJson.map(
        (key, value) => MapEntry(key, value as String),
      ),
    );
  }
}

class DummyDataService {
  DummyDataService._();

  static const _assetPath = 'assets/data/dummy_data.json';

  static DummyDataService? _instance;
  static Future<DummyDataService>? _loading;

  static Future<DummyDataService> get instance {
    _loading ??= _load();
    return _loading!;
  }

  static Future<DummyDataService> _load() async {
    if (_instance != null) return _instance!;

    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    _instance = DummyDataService._()
      .._home = DummyHomeData.fromJson(json['home'] as Map<String, dynamic>)
      .._profile =
          DummyProfileData.fromJson(json['profile'] as Map<String, dynamic>);

    return _instance!;
  }

  late final DummyHomeData _home;
  late final DummyProfileData _profile;

  DummyHomeData get home => _home;
  DummyProfileData get profile => _profile;
}
