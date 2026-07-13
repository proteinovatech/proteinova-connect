import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/admin%20branch/data/models/admin_branch_dashboard_model.dart';
import 'sales_dashboard_event.dart';
import 'sales_dashboard_state.dart';
import '../data/datasource/sales_remote_datasource.dart';

class SalesDashboardBloc
    extends Bloc<SalesDashboardEvent, SalesDashboardState> {

  final SalesRemoteDatasource datasource;

  SalesDashboardBloc(this.datasource)
      : super(SalesDashboardInitial()) {

    on<FetchSalesDashboard>(_onFetchSalesDashboard);
    on<FetchBranchDashboard>(_onFetchBranchDashboard);
    on<SelectBranch>(_onSelectBranch);
    on<RefreshBranchDashboard>(_onRefreshBranchDashboard);
  }

  // ── Legacy: Sales table fetch ──
Future<void> _onFetchSalesDashboard(
  FetchSalesDashboard event,
  Emitter<SalesDashboardState> emit,
) async {
  emit(SalesDashboardLoading());

  try {
    final branchesRaw = await datasource.getBranchesList();

    final branches = branchesRaw
        .map<BranchModel>((e) => BranchModel.fromJson(e))
        .toList();

    final response = await datasource.getSales(
      branchId: event.branchId,
      date: event.date,
    );

    final recentOrders =
        response["sales"] ??
        response["recent_orders"] ??
        response["data"] ??
        [];

    emit(
      SalesDashboardLoaded(
        salesData: response,
        recentOrders: recentOrders,
        branches: branches,
      ),
    );
  } catch (e) {
    emit(SalesDashboardError(e.toString()));
  }
}
  // ── Branch Dashboard: initial load ──
  Future<void> _onFetchBranchDashboard(
    FetchBranchDashboard event,
    Emitter<SalesDashboardState> emit,
  ) async {
    emit(BranchDashboardLoading());
    try {
      // 1. Fetch branches list
      final branchesRaw = await datasource.getBranchesList();
      final branches = branchesRaw.map((e) => BranchModel.fromJson(e)).toList();

      // 2. Decide initial selected branch
      int? selectedId = event.branchId;
      if (selectedId == null && branches.isNotEmpty) {
        selectedId = branches.first.id;
      }

      // 3. Fetch dashboard for selected branch
      final dashboardJson = await datasource.getBranchDashboard(branchId: selectedId);
      final dashboard = AdminBranchDashboardModel.fromJson(dashboardJson);

      emit(BranchDashboardLoaded(
        branches: branches,
        selectedBranchId: selectedId,
        dashboard: dashboard,
      ));
    } catch (e) {
      emit(BranchDashboardError(e.toString()));
    }
  }

  // ── Branch Dashboard: select branch ──
  Future<void> _onSelectBranch(
    SelectBranch event,
    Emitter<SalesDashboardState> emit,
  ) async {
    final currentState = state;
    List<BranchModel> branches = [];
    if (currentState is BranchDashboardLoaded) {
      branches = currentState.branches;
    }

    emit(BranchDashboardLoading());
    try {
      if (branches.isEmpty) {
        final branchesRaw = await datasource.getBranchesList();
        branches = branchesRaw.map((e) => BranchModel.fromJson(e)).toList();
      }

      final dashboardJson = await datasource.getBranchDashboard(branchId: event.branchId);
      final dashboard = AdminBranchDashboardModel.fromJson(dashboardJson);

      emit(BranchDashboardLoaded(
        branches: branches,
        selectedBranchId: event.branchId,
        dashboard: dashboard,
      ));
    } catch (e) {
      emit(BranchDashboardError(e.toString()));
    }
  }

  // ── Branch Dashboard: refresh ──
  Future<void> _onRefreshBranchDashboard(
    RefreshBranchDashboard event,
    Emitter<SalesDashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is BranchDashboardLoaded) {
      try {
        final branchesRaw = await datasource.getBranchesList();
        final branches = branchesRaw.map((e) => BranchModel.fromJson(e)).toList();
        final selectedId = event.branchId ?? currentState.selectedBranchId;
        final dashboardJson = await datasource.getBranchDashboard(branchId: selectedId);
        final dashboard = AdminBranchDashboardModel.fromJson(dashboardJson);
        emit(BranchDashboardLoaded(
          branches: branches,
          selectedBranchId: selectedId,
          dashboard: dashboard,
        ));
      } catch (e) {
        emit(BranchDashboardError(e.toString()));
      }
    } else {
      add(FetchBranchDashboard(branchId: event.branchId));
    }
  }
}