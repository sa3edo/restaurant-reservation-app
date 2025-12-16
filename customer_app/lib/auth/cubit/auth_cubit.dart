//cubit/auth_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit(this.authService) : super(AuthInitial()) {
    _authSubscription = authService.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    print(
      '=======================Auth state changed: $user =================/n',
    );
    if (user == null) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(user));
    }
  }

 Future<void> login(String email, String password) async {
  emit(AuthLoading());
  try {
    final user = await authService.login(email: email, password: password);
    if (user == null) {
      emit(AuthError('No user found for that email'));
    } else {
      emit(AuthAuthenticated(user));
    }
  } on FirebaseAuthException catch (e) {
    String message = 'Login failed';
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'invalid-email':
        message = 'Invalid email format';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Try again later';
        break;
      default:
        message = e.message ?? 'Login failed';
    }
    emit(AuthError(message));
  } catch (e) {
    emit(AuthError('Something went wrong'));
  }
}


  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      await authService.register(email: email, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await authService.logout();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
