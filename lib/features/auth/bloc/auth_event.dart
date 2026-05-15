abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String role;

  LoginRequested({
    required this.email,
    required this.password,
    required this.role
  });
}

class LogoutRequested extends AuthEvent {}