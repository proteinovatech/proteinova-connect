import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/daily_closing_admin_service.dart';
import 'daily_closing_admin_event.dart';
import 'daily_closing_admin_state.dart';

class DailyClosingAdminBloc extends Bloc<DailyClosingAdminEvent, DailyClosingAdminState> {
  final DailyClosingAdminService service;

  DailyClosingAdminBloc(this.service) : super(DailyClosingAdminState()) {
    on<LoadBranchesEvent>(_onLoadBranches);
    on<SelectBranchEvent>(_onSelectBranch);
    on<SubmitDayClosingEvent>(_onSubmitDayClosing);
  }

  Future<void> _onLoadBranches(
    LoadBranchesEvent event,
    Emitter<DailyClosingAdminState> emit,
  ) async {
    emit(state.copyWith(isBranchesLoading: true, clearError: true));
    try {
      final branches = await service.fetchBranches();
      if (branches.isNotEmpty) {
        emit(state.copyWith(
          isBranchesLoading: false,
          branches: branches,
          selectedBranchId: branches.first.id,
        ));
        add(SelectBranchEvent(branches.first.id));
      } else {
        emit(state.copyWith(isBranchesLoading: false, branches: const []));
      }
    } catch (e) {
      emit(state.copyWith(isBranchesLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSelectBranch(
    SelectBranchEvent event,
    Emitter<DailyClosingAdminState> emit,
  ) async {
    emit(state.copyWith(
      isDashboardLoading: true,
      selectedBranchId: event.branchId,
      clearError: true,
    ));
    try {
      final dashboardData = await service.fetchDashboardData(event.branchId);
      emit(state.copyWith(
        isDashboardLoading: false,
        dashboardData: dashboardData,
      ));
    } catch (e) {
      emit(state.copyWith(isDashboardLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSubmitDayClosing(
    SubmitDayClosingEvent event,
    Emitter<DailyClosingAdminState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, submitSuccess: false, clearError: true));
    try {
      await service.submitDailyClosing(
        branchId: event.branchId,
        status: event.status,
        notes: event.notes,
        countedCash: event.countedCash,
      );
      emit(state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
        successMessage: event.status == "CLOSED"
            ? "Day closed successfully!"
            : "Draft saved successfully!",
      ));
      // Reload dashboard after successful submission
      add(SelectBranchEvent(event.branchId));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}
