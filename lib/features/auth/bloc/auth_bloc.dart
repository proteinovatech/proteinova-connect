
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
   on<LoginRequested>((event, emit) async {
  emit(AuthLoading());

  try {
    final result = await AuthService.login(
      email: event.email,
      password: event.password,
      role: event.role.toLowerCase(),
    );

    if (result != null && result['user'] != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('role', result['user']['role']);

      if (result['user']['role'] == "purchase") {
        emit(AuthSuccessPurchase());
      } else {
        emit(AuthSuccessBranch());
      }
    } else {
      emit(AuthFailure("Login failed"));
    }
  } catch (e) {
    emit(AuthFailure("Something went wrong"));
  }
});
  }
}