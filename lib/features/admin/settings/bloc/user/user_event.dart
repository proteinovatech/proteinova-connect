part of 'user_bloc.dart';

abstract class UserEvent {}

class FetchUsersEvent extends UserEvent {}

class SaveUserEvent extends UserEvent {
  final Map<String, dynamic> userData;
  final int? userId;

  SaveUserEvent({
    required this.userData,
    this.userId,
  });
}

class DeleteUserEvent extends UserEvent {
  final int userId;

  DeleteUserEvent(this.userId);
}