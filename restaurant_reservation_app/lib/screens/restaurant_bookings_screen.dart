// screens/restaurant_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/booking_service.dart';

class RestaurantBookingsScreen extends StatelessWidget {
  final String restaurantId;
  final String restaurantName;

  RestaurantBookingsScreen({
    required this.restaurantId,
    required this.restaurantName,
  });

  final bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          restaurantName,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingService.getRestaurantBookings(restaurantId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                'No bookings yet',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Card(
                color: Colors.grey[900], 
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Icons.event_seat,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Table ${booking['tableNumber']} - ${booking['timeSlot']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('customers')
                        .doc(booking['customerId'])
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        );
                      }

                      final data = snapshot.data!.data();
                      if (data == null) {
                        return Text(
                          'Date: ${booking['date']}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        );
                      }

                      final customerData = data as Map<String, dynamic>;

                      return Text(
                        '${customerData['name'] ?? 'Unknown'} | Date: ${booking['date']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),

                  trailing: Text(
                    'Seats: ${booking['seats']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
