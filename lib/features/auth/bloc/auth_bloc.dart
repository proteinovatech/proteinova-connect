import 'package:proteinova_connect/services/auth_services.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      final result = await AuthService.login(
        email: event.email,
        password: event.password,
      );

      if (result != null && result["status"] == 1) {
        emit(AuthSuccess(result["user"]));
      } else {
        emit(AuthFailure("Login failed"));
      }
    });
  }
}