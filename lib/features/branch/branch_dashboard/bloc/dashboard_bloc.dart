import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/repository/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(DashboardInitial()) {
    on<FetchDashboardEvent>(_fetchDashboard);
    on<RefreshDashboardEvent>(_refreshDashboard);
  }

  Future<void> _fetchDashboard(
    FetchDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final result = await repository.fetchDashboardData();

emit(DashboardLoaded(result));

      emit(DashboardLoaded(result));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _refreshDashboard(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final result = await repository.fetchDashboardData();

      emit(DashboardLoaded(result));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}