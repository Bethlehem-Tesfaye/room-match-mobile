import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get host {
    if (kIsWeb) return 'http://localhost:3000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      default:
        return 'http://localhost:3000';
    }
  }

  static String get apiBaseUrl => '$host/api';

  static String resolveUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) return '$host$path';
    return '$host/$path';
  }
}
