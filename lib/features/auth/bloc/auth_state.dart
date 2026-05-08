abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}
class AuthSuccessPurchase extends AuthState {}   

class AuthSuccessBranch extends AuthState {} 

class AuthSuccess extends AuthState {
  final Map<String, dynamic> user;
  final String role;

  AuthSuccess(this.user,this.role);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}