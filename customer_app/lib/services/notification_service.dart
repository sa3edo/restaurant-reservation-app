
  import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

class NotificationSender {
  final _firestore = FirebaseFirestore.instance;

  Future<void> sendBookingNotification({
    required String restaurantName,
    required String date,
    required String timeSlot,
    required String seats,
  }) async {
    final doc = await _firestore.collection('vendor').doc('main').get();

    if (!doc.exists) return;

    final token = doc['fcmToken'];
    // final token = "c8ecAiStQRys4YWC7mleBV:APA91bHQWskHIgKJv-E52FnVZkFSQzogHL4uChVgixbizieVJVWHr-Xeav3QH2ouqXnq1ZZV-tBRLRHN4loFJstN_u9gITbLwHGStyVek6p3bt5GvDHmz20";

  
    final jsonString = await rootBundle.loadString(
      'assets/firebase/restaurant-reservation-a-fc826-firebase-adminsdk-fbsvc-2eee802827.json',
    );
    final jsonMap = jsonDecode(jsonString);

    final projectId = jsonMap['project_id'];
    final credentials = ServiceAccountCredentials.fromJson(jsonMap);

    final client = await clientViaServiceAccount(credentials, [
      'https://www.googleapis.com/auth/firebase.messaging',
    ]);

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final payload = {
      "message": {
        "token": token,
        "data": {
          "title": "New Booking",
          "body": "$restaurantName • seats: $seats \n$date • $timeSlot",
        },
      },
    };

    await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    client.close();
  }
}  