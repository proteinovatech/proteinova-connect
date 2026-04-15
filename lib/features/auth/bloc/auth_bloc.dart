
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
   on<LoginRequested>((event, emit) async {
  emit(AuthLoading());

  // 🔥 Navigate immediately
  if (event.role == "Purchase") {
    emit(AuthSuccessPurchase());
  } else {
    emit(AuthSuccessBranch());
  }

  // 🔄 Run API in background
  final result = await AuthService.login(
    email: event.email,
    password: event.password,
    role: event.role.toLowerCase(),
  );

  print("API finished later: $result");
});
  }
}