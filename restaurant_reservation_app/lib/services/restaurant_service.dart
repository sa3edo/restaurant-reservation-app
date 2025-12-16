// services/restaurant_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantService {
  final _firestore = FirebaseFirestore.instance;

  Future<String> encodeImage(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> addRestaurant({
    required String name,
    required String description,
    required String imageBase64,
    required String categoryId,
    required String categoryName,
    required int tables,
    required double lat,
    required double lng,
  }) async {
    await _firestore.collection('restaurants').add({
      'name': name,
      'description': description,
      'imageBase64': imageBase64,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'tablesCount': tables,
      'maxSeatsPerTable': 6,
      'timeSlots': ['10:00 AM', '12:00 PM', '02:00 PM', '04:00 PM', '06:00 PM'],
      'location': {'lat': lat, 'lng': lng},
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateRestaurant({
    required String id,
    required String name,
    required String description,
    required String imageBase64,
    required String categoryId,
    required String categoryName,
    required int tables,
    required double lat,
    required double lng,
  }) async {
    await _firestore.collection('restaurants').doc(id).update({
      'name': name,
      'description': description,
      'imageBase64': imageBase64,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'tablesCount': tables,
      'location': {'lat': lat, 'lng': lng},
    });
  }
}
