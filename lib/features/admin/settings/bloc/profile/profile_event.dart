abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class SaveProfileEvent extends ProfileEvent {
  final String email;
  final String role;
  final String password;

  SaveProfileEvent({
    required this.email,
    required this.role,
    required this.password,
  });
}