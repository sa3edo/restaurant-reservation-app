// widgets/restaurant_card.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantCard extends StatelessWidget {
  final QueryDocumentSnapshot restaurant;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onViewBookings;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.onLongPress,
    required this.onViewBookings,
  });

  Uint8List _decodeImage() {
    try {
      final raw = restaurant['imageBase64'];
      if (raw == null || raw.toString().isEmpty) {
        return Uint8List(0);
      }

      final String cleanBase64 = raw.toString().contains(',')
          ? raw.toString().split(',').last
          : raw.toString();

      return base64Decode(cleanBase64);
    } catch (_) {
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _decodeImage();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        color: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Expanded(
              child: imageBytes.isNotEmpty
                  ? Image.memory(
                      imageBytes,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      color: Colors.black26,
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white38,
                        size: 40,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant['categoryName'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onViewBookings,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View bookings',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
