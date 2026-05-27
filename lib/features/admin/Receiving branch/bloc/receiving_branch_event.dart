part of 'receiving_branch_bloc.dart';

abstract class ReceivingBranchEvent {}

class FetchBranchesListEvent extends ReceivingBranchEvent {}

class SelectBranchEvent extends ReceivingBranchEvent {
  final int branchId;

  SelectBranchEvent(this.branchId);
}

class TriggerMarkArrivalEvent extends ReceivingBranchEvent {
  final int branchId;
  final int dispatchId;

  TriggerMarkArrivalEvent({required this.branchId, required this.dispatchId});
}

class LoadDispatchDetailsEvent extends ReceivingBranchEvent {
  final int branchId;
  final int dispatchId;

  LoadDispatchDetailsEvent({required this.branchId, required this.dispatchId});
}

class ConfirmDispatchReceiveEvent extends ReceivingBranchEvent {
  final int branchId;
  final int dispatchId;
  final List<Map<String, dynamic>> items;
  final String notes;

  ConfirmDispatchReceiveEvent({
    required this.branchId,
    required this.dispatchId,
    required this.items,
    required this.notes,
  });
}
