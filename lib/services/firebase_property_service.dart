import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_options.dart';
import '../models/property.dart';

class FirebaseNotConfiguredException implements Exception {
  FirebaseNotConfiguredException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FirebasePropertyService {
  FirebasePropertyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String collectionName = 'properties';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionName);

  Stream<List<Property>> watchProperties() {
    if (!DefaultFirebaseOptions.isConfigured) {
      return Stream.value(const []);
    }

    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Property.fromFirestore).toList(growable: false),
        );
  }

  Future<String> addProperty(Property property) async {
    if (!DefaultFirebaseOptions.isConfigured) {
      throw FirebaseNotConfiguredException(
        'Firebase is not configured. Run `flutterfire configure` in the Front-End folder.',
      );
    }

    final docRef = await _collection.add(property.toMap()).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException(
          'Publishing timed out. Check your internet connection and Firebase setup.',
        );
      },
    );
    return docRef.id;
  }
}
