part of 'branch_form_bloc.dart';

abstract class BranchFormState {}

class BranchFormInitial extends BranchFormState {}

class BranchFormLoading extends BranchFormState {}

class BranchFormLoaded extends BranchFormState {
  final List<String> statuses;
  final List<String> regions;
  final List<ManagerModel> managers;

  BranchFormLoaded({
    required this.statuses,
    required this.regions,
    required this.managers,
  });
}

class BranchFormSubmitting extends BranchFormState {}

class BranchFormSuccess extends BranchFormState {
  final String message;

  BranchFormSuccess(this.message);
}

class BranchFormError extends BranchFormState {
  final String message;

  BranchFormError(this.message);
}