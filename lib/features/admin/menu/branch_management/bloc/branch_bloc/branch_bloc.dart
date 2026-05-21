import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/services/branch_service.dart';

part 'branch_event.dart';
part 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final BranchService branchService;

  BranchBloc(this.branchService) : super(BranchInitial()) {

    on<LoadBranchesEvent>((event, emit) async {
      emit(BranchLoading());

      try {
        final data = await branchService.fetchBranches();

        emit(BranchLoaded(data));
      } catch (e) {
        emit(BranchError(e.toString()));
      }
    });

    on<RefreshBranchesEvent>((event, emit) async {
      try {
        final data = await branchService.fetchBranches();

        emit(BranchLoaded(data));
      } catch (e) {
        emit(BranchError(e.toString()));
      }
    });

    on<DeleteBranchEvent>((event, emit) async {

      if (state is BranchLoaded) {

        final currentState = state as BranchLoaded;

        try {

          await branchService.deleteBranch(event.branchId);

          final updatedBranches =
              currentState.branches
                  .where((e) => e.id != event.branchId)
                  .toList();

          emit(BranchLoaded(updatedBranches));

        } catch (e) {
          emit(BranchError(e.toString()));
        }
      }
    });
  }
}