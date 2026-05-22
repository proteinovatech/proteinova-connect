part of 'branch_form_bloc.dart';

abstract class BranchFormEvent {}

class LoadBranchFormDataEvent extends BranchFormEvent {}

class CreateBranchEvent extends BranchFormEvent {
  final Map<String, dynamic> body;

  CreateBranchEvent(this.body);
}

class UpdateBranchEvent extends BranchFormEvent {
  final int id;
  final Map<String, dynamic> body;

  UpdateBranchEvent({
    required this.id,
    required this.body,
  });
}