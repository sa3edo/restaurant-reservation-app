//notification_helper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> saveNotificationFromData({
  required FirebaseFirestore firestore,
  required String title,
  required String body,
}) async {
  await firestore.collection('vendor_notifications').add({
    'title': title,
    'body': body,
    'createdAt': Timestamp.now(),
  });
}

Future<void> showLocalNotificationFromData({
  required FlutterLocalNotificationsPlugin local,
  required String title,
  required String body,
}) async {
  const android = AndroidNotificationDetails(
    'vendor_channel',
    'Vendor Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  await local.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    const NotificationDetails(android: android),
  );
}

//customer : service , token(receiver)   , get service account (fire base admin api) , create client to send noti using service account , get api url which we send fcm , type noti body , send noti , 