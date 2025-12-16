import 'package:customer_app/auth/auth_wrapper.dart';
import 'package:customer_app/auth/cubit/auth_cubit.dart';
import 'package:customer_app/auth/cubit/auth_state.dart';
import 'package:customer_app/auth/screens/login_screen.dart';
import 'package:customer_app/home/home_screen.dart';
import 'package:customer_app/providers/booking_provider.dart';
import 'package:customer_app/providers/restaurant_provider.dart';
import 'package:customer_app/auth/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:customer_app/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: BlocProvider(
        create: (_) => AuthCubit(AuthService()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customer App',
      theme: ThemeData(
      ),

      home: const AuthWrapper(),
    );
  }
}
