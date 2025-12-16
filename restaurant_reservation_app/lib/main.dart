 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_reservation_app/firebase_options.dart';
import 'package:restaurant_reservation_app/home/vendor_home_screen.dart';
import 'package:restaurant_reservation_app/providers/restaurant_provider.dart';
import 'package:restaurant_reservation_app/screens/vendor_notification_screen.dart';
import 'package:restaurant_reservation_app/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final local = FlutterLocalNotificationsPlugin();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidInit);

  await local.initialize(settings);

  final title = message.data['title'] ?? 'New Booking';
  final body = message.data['body'] ?? '';

  await firestore.collection('vendor_notifications').add({
    'title': title,
    'body': body,
    'createdAt': Timestamp.now(),
  });

  await local.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'vendor_channel',
        'Vendor Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  NotificationService.navigatorKey = navigatorKey;
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RestaurantProvider()..listenToRestaurants(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,
      routes: {
        VendorNotificationsScreen.routeName: (_) =>
            const VendorNotificationsScreen(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 20, 216, 154),
        ),
      ),
      home: VendorHomeScreen(),
    );
  }
} 