import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:proteinova_connect/features/admin/add%20branch/data/repository/add_branch_repository.dart';
import 'add_branch_event.dart';
import 'add_branch_state.dart';

class AddBranchBloc extends Bloc<AddBranchEvent, AddBranchState> {
  final AddBranchRepository repository;

  AddBranchBloc(this.repository) : super(AddBranchInitial()) {
    on<LoadFormOptionsEvent>(_onLoadFormOptions);
    on<SaveBranchEvent>(_onSaveBranch);
  }

  Future<void> _onLoadFormOptions(
    LoadFormOptionsEvent event,
    Emitter<AddBranchState> emit,
  ) async {
    emit(AddBranchFormLoading());
    try {
      final options = await repository.fetchBranchFormOptions();
      emit(AddBranchFormLoaded(options));
    } catch (e) {
      String errorMessage = "Failed to load form options";
      if (e is DioException) {
        errorMessage = e.response?.data?['error'] ?? e.message ?? e.toString();
      } else {
        errorMessage = e.toString();
      }
      emit(AddBranchFailure(errorMessage));
    }
  }

  Future<void> _onSaveBranch(
    SaveBranchEvent event,
    Emitter<AddBranchState> emit,
  ) async {
    emit(AddBranchSubmitting());
    try {
      if (event.isEditing) {
        if (event.branchId == null) {
          throw Exception("Branch ID is required for updating");
        }
        await repository.updateBranch(event.branchId!, event.payload);
        emit(AddBranchSuccess("Branch updated successfully!"));
      } else {
        await repository.createBranch(event.payload);
        emit(AddBranchSuccess("Branch created successfully!"));
      }
    } catch (e) {
      String errorMessage = "Failed to save branch";
      if (e is DioException) {
        errorMessage = e.response?.data?['error'] ?? e.message ?? e.toString();
      } else {
        errorMessage = e.toString();
      }
      emit(AddBranchFailure(errorMessage));
    }
  }
}
