//restaurant_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _service = RestaurantService();

  List<QueryDocumentSnapshot> _restaurants = [];
  List<QueryDocumentSnapshot> get restaurants => _restaurants;

  bool _loading = false;
  bool get isLoading => _loading;

  void listenToRestaurants({String? categoryId, String? search}) {
    _loading = true;
    notifyListeners();

    _service.getRestaurants(categoryId: categoryId).listen((snapshot) {
      var docs = snapshot.docs;

      if (search != null && search.isNotEmpty) {
        docs = docs.where((doc) {
          final name = (doc['name'] as String).toLowerCase();
          return name.contains(search.toLowerCase());
        }).toList();
      }

      _restaurants = docs;
      _loading = false;
      notifyListeners();
    });
  }

  Future<DocumentSnapshot> getRestaurantById(String id) {
    return _service.getRestaurantById(id);
  }
}
