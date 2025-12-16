import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final QueryDocumentSnapshot restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final image = base64Decode(widget.restaurant['imageBase64']);
    final int tablesCount = widget.restaurant['tablesCount'];

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.red),
        title: Text(
          widget.restaurant['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Image.memory(
                image,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.restaurant['description'],
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _infoChip(
                        Icons.category,
                        widget.restaurant['categoryName'],
                      ),
                      _infoChip(Icons.table_bar, 'Tables: $tablesCount'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  if (selectedDate == null)
                    const Text(
                      'Please select a date to view tables',
                      style: TextStyle(color: Colors.white70),
                    )
                  else
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(widget.restaurant.id)
                          .collection('bookings')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          );
                        }

                        final bookedTables = snapshot.hasData
                            ? snapshot.data!.docs
                                  .where((doc) {
                                    final rawDate = doc['date'];

                                    if (rawDate == null ||
                                        rawDate == '' ||
                                        rawDate == 'Select date') {
                                      return false;
                                    }

                                    DateTime bookingDate;

                                    try {
                                      bookingDate = DateTime.parse(rawDate);
                                    } catch (e) {
                                      return false; 
                                    }

                                    return bookingDate.year ==
                                            selectedDate!.year &&
                                        bookingDate.month ==
                                            selectedDate!.month &&
                                        bookingDate.day == selectedDate!.day;
                                  })
                                  .map((e) => e['tableNumber'] as int)
                                  .toSet()
                            : <int>{};

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tablesCount,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final tableNumber = index + 1;
                            final isBooked = bookedTables.contains(tableNumber);

                            return Container(
                              decoration: BoxDecoration(
                                color: isBooked
                                    ? Colors.red.shade700
                                    : Colors.green.shade600,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.table_restaurant,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Table $tableNumber',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isBooked ? 'Booked' : 'Available',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.red, size: 18),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
