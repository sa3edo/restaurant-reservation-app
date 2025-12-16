//restaurant_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getRestaurants({String? categoryId}) {
    Query query = _db.collection('restaurants');

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query.snapshots();
  }

  Future<DocumentSnapshot> getRestaurantById(String id) {
    return _db.collection('restaurants').doc(id).get();
  }
}
