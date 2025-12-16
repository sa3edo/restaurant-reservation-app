// services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getVendorRestaurants() {
    return _firestore.collection('restaurants').snapshots();
  }

  Stream<QuerySnapshot> getRestaurantBookings(String restaurantId) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
