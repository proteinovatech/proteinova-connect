part of 'user_bloc.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<dynamic> users;
  final Map<String, dynamic> formOptions;

  UserLoaded({
    required this.users,
    required this.formOptions,
  });
}

class UserActionSuccess extends UserState {
  final String message;

  UserActionSuccess(this.message);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}