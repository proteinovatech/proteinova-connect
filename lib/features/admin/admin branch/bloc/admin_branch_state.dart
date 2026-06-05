import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/admin%20branch/data/models/admin_branch_dashboard_model.dart';

abstract class AdminBranchState {}

class AdminBranchInitial extends AdminBranchState {}

class AdminBranchLoading extends AdminBranchState {}

class AdminBranchLoaded extends AdminBranchState {
  final List<BranchModel> branches;
  final int? selectedBranchId;
  final AdminBranchDashboardModel dashboard;

  AdminBranchLoaded({
    required this.branches,
    required this.selectedBranchId,
    required this.dashboard,
  });
}

class AdminBranchError extends AdminBranchState {
  final String message;

  AdminBranchError(this.message);
}
