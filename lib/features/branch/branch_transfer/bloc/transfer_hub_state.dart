abstract class TransferHubState {}

class TransferHubInitial extends TransferHubState {}

class TransferHubLoading extends TransferHubState {}

class TransferHubLoaded extends TransferHubState {
  final Map<String, dynamic> data;
  TransferHubLoaded({required this.data});
}

class TransferHubError extends TransferHubState {
  final String message;
  TransferHubError({required this.message});
}
