import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import '../data/repository/admin_branch_repository.dart';
import 'admin_branch_event.dart';
import 'admin_branch_state.dart';

class AdminBranchBloc extends Bloc<AdminBranchEvent, AdminBranchState> {
  final AdminBranchRepository repository;

  AdminBranchBloc(this.repository) : super(AdminBranchInitial()) {
    on<LoadAdminBranchDashboardEvent>(_onLoadDashboard);
    on<SelectBranchEvent>(_onSelectBranch);
    on<RefreshAdminBranchDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadAdminBranchDashboardEvent event,
    Emitter<AdminBranchState> emit,
  ) async {
    emit(AdminBranchLoading());
    try {
      // 1. Fetch branches
      final List<BranchModel> branches = await repository.fetchBranches();

      // 2. Decide initial selected branch
      int? selectedId = event.branchId;
      if (selectedId == null && branches.isNotEmpty) {
        selectedId = branches.first.id;
      }

      // 3. Fetch dashboard for selected branch
      final dashboard = await repository.fetchDashboardData(selectedId);

      emit(AdminBranchLoaded(
        branches: branches,
        selectedBranchId: selectedId,
        dashboard: dashboard,
      ));
    } catch (e) {
      emit(AdminBranchError(e.toString()));
    }
  }

  Future<void> _onSelectBranch(
    SelectBranchEvent event,
    Emitter<AdminBranchState> emit,
  ) async {
    final currentState = state;
    List<BranchModel> branches = [];
    if (currentState is AdminBranchLoaded) {
      branches = currentState.branches;
    }

    emit(AdminBranchLoading());
    try {
      if (branches.isEmpty) {
        branches = await repository.fetchBranches();
      }

      final dashboard = await repository.fetchDashboardData(event.branchId);

      emit(AdminBranchLoaded(
        branches: branches,
        selectedBranchId: event.branchId,
        dashboard: dashboard,
      ));
    } catch (e) {
      emit(AdminBranchError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshAdminBranchDashboardEvent event,
    Emitter<AdminBranchState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminBranchLoaded) {
      try {
        final branches = await repository.fetchBranches();
        final selectedId = event.branchId ?? currentState.selectedBranchId;
        final dashboard = await repository.fetchDashboardData(selectedId);
        emit(AdminBranchLoaded(
          branches: branches,
          selectedBranchId: selectedId,
          dashboard: dashboard,
        ));
      } catch (e) {
        emit(AdminBranchError(e.toString()));
      }
    } else {
      add(LoadAdminBranchDashboardEvent(branchId: event.branchId));
    }
  }
}
