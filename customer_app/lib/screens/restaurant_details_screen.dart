import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/screens/book_table_screen.dart';
import 'package:customer_app/providers/booking_provider.dart';
import 'package:customer_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;
  final String customerId = FirebaseAuth.instance.currentUser!.uid;

  RestaurantDetailsScreen(this.restaurantId);

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  int? selectedTable;
  DateTime? selectedDate;
  int maxSeats = 6;

  String get formattedDate => selectedDate == null
      ? 'Select Date'
      : '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}';

  bool tableFullyBooked(int tableNumber) {
    final timeSlots = [
      '10:00 AM',
      '12:00 PM',
      '02:00 PM',
      '04:00 PM',
      '06:00 PM',
    ];

    return timeSlots.every(
      (time) => context.read<BookingProvider>().isTimeBooked(
        tableNumber: tableNumber,
        timeSlot: time,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Item Details', style: TextStyle(color: Colors.red)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final map = data.data() as Map<String, dynamic>;

          final Uint8List imageBytes = base64Decode(map['imageBase64']);
          final String name = map['name'] ?? 'Restaurant';
          final String description =
              map['description'] ?? 'there is no description';
          final String category = map['categoryName'] ?? '';
          final int tablesCount = map['tablesCount'];
          maxSeats = map['maxSeatsPerTable'] ?? 6;

          return Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.memory(
                  imageBytes,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star_half, color: Colors.amber, size: 18),
                          SizedBox(width: 8),
                          Text(
                            '4.5 (23 Reviews)',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'About Restaurant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.red,
                        ),
                        label: Text(
                          formattedDate,
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                              selectedTable = null;
                            });

                            context
                                .read<BookingProvider>()
                                .listenToReservationsForRestaurant(
                                  widget.restaurantId,
                                  formattedDate,
                                );
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Select Table',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 240,
                        child: selectedDate == null
                            ? const Center(
                                child: Text(
                                  'Please select a date first',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                    ),
                                itemCount: tablesCount,
                                itemBuilder: (context, index) {
                                  final tableNumber = index + 1;
                                  return TableWidget(
                                    tableNumber: tableNumber,
                                    isSelected: selectedTable == tableNumber,
                                    isBooked: tableFullyBooked(tableNumber),
                                    onTap: () {
                                      setState(() {
                                        selectedTable = tableNumber;
                                      });
                                    },
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Reviews',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      _reviewItem('Jane Doe', 'Amazing food and atmosphere!'),
                      _reviewItem(
                        'Ahmed Ali',
                        'Great service and clean place.',
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: selectedTable == null || selectedDate == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookTableScreen(
                        restaurantId: widget.restaurantId,
                        tableNumber: selectedTable!,
                        customerId: widget.customerId,
                        maxSeats: maxSeats,
                        date: formattedDate,
                      ),
                    ),
                  );
                },
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _reviewItem(String name, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (_) =>
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                  ),
                ),
                Text(comment, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
