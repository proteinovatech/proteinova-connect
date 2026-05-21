import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/model/branch_form_data_model.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/data/services/branch_service.dart';

part 'branch_form_event.dart';
part 'branch_form_state.dart';

class BranchFormBloc
    extends Bloc<BranchFormEvent, BranchFormState> {

  final BranchService branchService;

  BranchFormBloc(this.branchService)
      : super(BranchFormInitial()) {

    on<LoadBranchFormDataEvent>((event, emit) async {

      emit(BranchFormLoading());

      try {

        final data =
            await branchService.fetchBranchFormData();

        emit(
          BranchFormLoaded(
            statuses: data.statuses,
            regions: data.regions,
            managers: data.managers,
          ),
        );

      } catch (e) {

        emit(
          BranchFormError(e.toString()),
        );
      }
    });

    on<CreateBranchEvent>((event, emit) async {

      emit(BranchFormSubmitting());

      try {

        await branchService.createBranch(
          data: event.body,
        );

        emit(
          BranchFormSuccess(
            "Branch Created Successfully",
          ),
        );

      } catch (e) {

        emit(
          BranchFormError(e.toString()),
        );
      }
    });

    on<UpdateBranchEvent>((event, emit) async {

      emit(BranchFormSubmitting());

      try {

        await branchService.updateBranch(
          id: event.id,
          data: event.body,
        );

        emit(
          BranchFormSuccess(
            "Branch Updated Successfully",
          ),
        );

      } catch (e) {

        emit(
          BranchFormError(e.toString()),
        );
      }
    });
  }
}