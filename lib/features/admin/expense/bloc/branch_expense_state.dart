import 'package:proteinova_connect/features/admin/expense/data/models/branch_expense_dashboard_model.dart';
import 'package:proteinova_connect/features/admin/expense/data/models/location_model.dart';

class BranchExpenseState {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool saveSuccess;
  final List<Location> locations;
  final BranchExpenseDashboardModel? dashboardData;

  const BranchExpenseState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.saveSuccess = false,
    this.locations = const [],
    this.dashboardData,
  });

  BranchExpenseState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? saveSuccess,
    List<Location>? locations,
    BranchExpenseDashboardModel? dashboardData,
  }) {
    return BranchExpenseState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      locations: locations ?? this.locations,
      dashboardData: dashboardData ?? this.dashboardData,
    );
  }
}