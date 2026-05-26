import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/services/auth_services.dart';
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
       print("FULL RESPONSE => $result");

if (result != null && result['user'] != null) {
  print("USER => ${result['user']}");
  print("ROLE => ${result['user']['role']}");
}
      

        if (result != null && result['user'] != null) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setBool('isLoggedIn', true);

          final String userRole = (result['user']['role'] ?? '').toString().trim().toLowerCase();
          await prefs.setString('role', userRole);

          if (result['user']['email'] != null) {
            await prefs.setString('email', result['user']['email']);
          }

          /// SAVE BRANCH ID

          final branchId = result['user']['branch_id'];
          final userId = result['user']['id'];

          print("BRANCH ID => $branchId");
          print("USER ID => $userId");
          
          await prefs.setInt('branch_id', branchId ?? 0);
          await prefs.setInt('user_id', userId ?? 0);

          if (userRole == "purchase") {
            emit(AuthSuccessPurchase());
          } else if (userRole == "branch") {
            emit(AuthSuccessBranch());
          } else if (userRole == "admin") {
            emit(AuthSuccessAdmin());
          } else {
            emit(AuthFailure("Invalid role"));
          }
        } else {
          emit(AuthFailure("Login failed"));
        }
      } catch (e) {
  print("LOGIN ERROR: $e");

  emit(AuthFailure(e.toString()));
}
    });

    on<LogoutRequested>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      emit(AuthInitial());
    });
  }
}
