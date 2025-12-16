import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _service = BookingService();

  List<QueryDocumentSnapshot> _reservations = [];
  List<QueryDocumentSnapshot> get reservations => _reservations;

  bool _loading = false;
  bool get isLoading => _loading;

  void listenToReservationsForRestaurant(String restaurantId, String date) {
    _loading = true;
    notifyListeners();

    _service.getReservationsForRestaurantByDate(restaurantId, date).listen((
      snapshot,
    ) {
      _reservations = snapshot.docs;
      _loading = false;
      notifyListeners();
    });
  }

  bool isTimeBooked({required int tableNumber, required String timeSlot}) {
    return _reservations.any(
      (r) => r['tableNumber'] == tableNumber && r['timeSlot'] == timeSlot,
    );
  }

  Future<void> bookTable({
    required String restaurantId,
    required int tableNumber,
    required int seats,
    required String date,
    required String customerId,
    required String timeSlot,
  }) async {
    await _service.bookTable(
      restaurantId: restaurantId,
      tableNumber: tableNumber,
      seats: seats,
      date: date,
      customerId: customerId,
      timeSlot: timeSlot,
    );

    final restaurantDoc = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .get();

    final restaurantName = restaurantDoc.data()?['name'] ?? 'Restaurant';

    await NotificationSender().sendBookingNotification(
      restaurantName: restaurantName,
      seats: '$seats',
      date: date,
      timeSlot: timeSlot,
    );
  }
}
