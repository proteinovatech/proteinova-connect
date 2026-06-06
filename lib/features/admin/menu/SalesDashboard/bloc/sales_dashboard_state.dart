import 'package:proteinova_connect/features/admin/admin%20branch/data/models/admin_branch_dashboard_model.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';

abstract class SalesDashboardState {}

class SalesDashboardInitial extends SalesDashboardState {}

class SalesDashboardLoading extends SalesDashboardState {}

class SalesDashboardLoaded extends SalesDashboardState {
  final Map<String, dynamic> salesData;
  final List recentOrders;

  SalesDashboardLoaded({
    required this.salesData,
    required this.recentOrders,
  });
}

class SalesDashboardError extends SalesDashboardState {
  final String message;

  SalesDashboardError(this.message);
}

/// States for the Branch Dashboard view
class BranchDashboardLoading extends SalesDashboardState {}

class BranchDashboardLoaded extends SalesDashboardState {
  final List<BranchModel> branches;
  final int? selectedBranchId;
  final AdminBranchDashboardModel dashboard;

  BranchDashboardLoaded({
    required this.branches,
    required this.selectedBranchId,
    required this.dashboard,
  });
}

class BranchDashboardError extends SalesDashboardState {
  final String message;
  BranchDashboardError(this.message);
}