abstract class TrayReceiveState {}

class TrayReceiveInitial extends TrayReceiveState {}

class TrayReceiveLoading extends TrayReceiveState {}

class TrayReceiveLoaded extends TrayReceiveState {
  final List<dynamic> receiveNotes;

  TrayReceiveLoaded(this.receiveNotes);
}

class TrayReceiveError extends TrayReceiveState {
  final String message;

  TrayReceiveError(this.message);
}