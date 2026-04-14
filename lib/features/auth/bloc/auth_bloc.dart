
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      final result = await AuthService.login(
        email: event.email,
        password: event.password,
        role:event.role
      );

      if (result != null && result["status"] == 1) {
        final prefs = await SharedPreferences.getInstance();

  await prefs.setBool("isLoggedIn", true);
  await prefs.setString("role", event.role);
        emit(AuthSuccess(result["user"], event.role));
      } else {
        emit(AuthFailure("Login failed"));
      }
    });
  }
}