part of 'branch_bloc.dart';

abstract class BranchEvent {}

class LoadBranchesEvent extends BranchEvent {}

class RefreshBranchesEvent extends BranchEvent {}

class DeleteBranchEvent extends BranchEvent {
  final int branchId;

  DeleteBranchEvent(this.branchId);
}