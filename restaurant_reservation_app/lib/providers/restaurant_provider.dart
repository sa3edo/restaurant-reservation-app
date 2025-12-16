// providers/restaurant_provider.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot> _restaurants = [];

  List<QueryDocumentSnapshot> get restaurants => _restaurants;

  StreamSubscription? _subscription;

  void listenToRestaurants() {
    _subscription?.cancel();

    _subscription = _db
        .collection('restaurants')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _restaurants = snapshot.docs;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
