part of 'branch_bloc.dart';

abstract class BranchState {}

class BranchInitial extends BranchState {}

class BranchLoading extends BranchState {}

class BranchLoaded extends BranchState {
  final List<BranchModel> branches;

  BranchLoaded(this.branches);
}

class BranchError extends BranchState {
  final String message;

  BranchError(this.message);
}