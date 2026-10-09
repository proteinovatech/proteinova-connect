abstract class TransferHubEvent {}

class LoadTransferHubEvent extends TransferHubEvent {
  final int branchId;
  LoadTransferHubEvent({required this.branchId});
}
