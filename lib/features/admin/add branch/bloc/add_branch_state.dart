import 'package:proteinova_connect/features/admin/add%20branch/data/models/branch_form_options_model.dart';

abstract class AddBranchState {}

class AddBranchInitial extends AddBranchState {}

class AddBranchFormLoading extends AddBranchState {}

class AddBranchFormLoaded extends AddBranchState {
  final BranchFormOptionsModel options;

  AddBranchFormLoaded(this.options);
}

class AddBranchSubmitting extends AddBranchState {}

class AddBranchSuccess extends AddBranchState {
  final String message;

  AddBranchSuccess(this.message);
}

class AddBranchFailure extends AddBranchState {
  final String error;

  AddBranchFailure(this.error);
}
