abstract class SalesState {}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesDashboardLoaded extends SalesState {
  final Map<String, dynamic> dashboardData;
  final List<dynamic> dispatches;
  final List<dynamic> salesOrders;

  SalesDashboardLoaded({
    required this.dashboardData,
    required this.dispatches,
    required this.salesOrders,
  });
}

class SalesSuccess extends SalesState {
  final String? message;
  SalesSuccess({this.message});
}

class SalesError extends SalesState {
  final String error;
  SalesError(this.error);
}