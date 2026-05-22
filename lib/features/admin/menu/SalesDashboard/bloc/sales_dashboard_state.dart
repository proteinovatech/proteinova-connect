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