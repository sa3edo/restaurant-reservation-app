//screens/auth_screen.dart
import 'package:customer_app/auth/screens/login_screen.dart';
import 'package:customer_app/auth/screens/register_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return isLogin
        ? LoginScreen(
            onSwitch: () {
              setState(() => isLogin = false);
            },
          )
        : RegisterScreen(
            onSwitch: () {
              setState(() => isLogin = true);
            },
          );
  }
}
