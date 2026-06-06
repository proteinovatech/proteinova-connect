abstract class SalesDashboardEvent {}

class FetchSalesDashboard extends SalesDashboardEvent {}

class FetchBranchDashboard extends SalesDashboardEvent {
  final int? branchId;
  FetchBranchDashboard({this.branchId});
}

class SelectBranch extends SalesDashboardEvent {
  final int branchId;
  SelectBranch(this.branchId);
}

class RefreshBranchDashboard extends SalesDashboardEvent {
  final int? branchId;
  RefreshBranchDashboard({this.branchId});
}