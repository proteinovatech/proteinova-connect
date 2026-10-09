abstract class BranchTransferEvent {}

class LoadInitialDataEvent extends BranchTransferEvent {
  final int loginUserId;
  final String branchName;
  final int branchId;
  LoadInitialDataEvent({required this.loginUserId, required this.branchName, required this.branchId});
}

class SubmitTransferEvent extends BranchTransferEvent {
  final Map<String, dynamic> payload;
  SubmitTransferEvent(this.payload);
}
