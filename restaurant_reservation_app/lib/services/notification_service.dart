//services/notification_service
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restaurant_reservation_app/screens/vendor_notification_screen.dart';
import 'package:restaurant_reservation_app/utils/notification_helper.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _local = FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState>? navigatorKey;
  //app oppened
  Future<void> init() async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    print('Vendor FCM Token: $token');

    if (token != null) {
      await _firestore.collection('vendor').doc('main').set({
        'fcmToken': token,
      });
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) {
        _openNotificationsScreen();
      },
    );
    //show when app oppened
    FirebaseMessaging.onMessage.listen((message) async {
      final title = message.data['title'];
      final body = message.data['body'];

      await saveNotificationFromData(
        firestore: _firestore,
        title: title,
        body: body,
      );

      await showLocalNotificationFromData(
        local: _local,
        title: title,
        body: body,
      );
    });
    //show when app oppened from noti
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final title = message.data['title'];
      final body = message.data['body'];

      await saveNotificationFromData(
        firestore: _firestore,
        title: title,
        body: body,
      );
      _openNotificationsScreen();
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _openNotificationsScreen();
    }
  }

  void _openNotificationsScreen() {
    navigatorKey?.currentState?.push(
  MaterialPageRoute(builder: (_) => VendorNotificationsScreen()),
);

  }

  // Future<void> showLocalNotification(RemoteMessage message) async {
  //   const android = AndroidNotificationDetails(
  //     'vendor_channel',
  //     'Vendor Notifications',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   const details = NotificationDetails(android: android);

  //   await _local.show(
  //     DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //     message.notification?.title ?? 'New Booking',
  //     message.notification?.body ?? '',
  //     details,
  //   );
  // }

  // Future<void> _saveNotification(RemoteMessage message) async {
  //   await _firestore.collection('vendor_notifications').add({
  //     'title': message.notification?.title ?? 'New Booking',
  //     'body': message.notification?.body ?? '',
  //     'createdAt': Timestamp.now(),
  //   });
  // }
}
