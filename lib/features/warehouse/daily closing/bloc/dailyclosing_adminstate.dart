import 'package:proteinova_connect/features/warehouse/daily%20closing/model/branchselector_model.dart';
import 'package:proteinova_connect/features/warehouse/daily%20closing/model/dailyclosing_adminmodel.dart';



class DailyClosingAdminState {
  final bool isBranchesLoading;
  final bool isDashboardLoading;
  final bool isSubmitting;
  final List<BranchSelectorModel> branches;
  final int? selectedBranchId;
  final DailyClosingAdminModel? dashboardData;
  final String? error;
  final bool submitSuccess;
  final String? successMessage;

  DailyClosingAdminState({
    this.isBranchesLoading = false,
    this.isDashboardLoading = false,
    this.isSubmitting = false,
    this.branches = const [],
    this.selectedBranchId,
    this.dashboardData,
    this.error,
    this.submitSuccess = false,
    this.successMessage,
  });

  DailyClosingAdminState copyWith({
    bool? isBranchesLoading,
    bool? isDashboardLoading,
    bool? isSubmitting,
    List<BranchSelectorModel>? branches,
    int? selectedBranchId,
    DailyClosingAdminModel? dashboardData,
    String? error,
    bool? submitSuccess,
    String? successMessage,
    bool clearError = false,
  }) {
    return DailyClosingAdminState(
      isBranchesLoading: isBranchesLoading ?? this.isBranchesLoading,
      isDashboardLoading: isDashboardLoading ?? this.isDashboardLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      branches: branches ?? this.branches,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
      dashboardData: dashboardData ?? this.dashboardData,
      error: clearError ? null : (error ?? this.error),
      submitSuccess: submitSuccess ?? this.submitSuccess,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
