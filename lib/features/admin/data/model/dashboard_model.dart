class DashboardModel {
  final int totalStockValue;
  final int totalStockEggs;
  final int inTransit;
  final int incomingStockEggs;
  final int dispatched;
  final int dispatchedStockEggs;
  final int branchSalesEggs;
  final String revenue;
  final String profit;
  final List<dynamic> recentActivity;
  DashboardModel({
    required this.totalStockValue,
    required this.totalStockEggs,
    required this.inTransit,
    required this.incomingStockEggs,
    required this.dispatched,
    required this.dispatchedStockEggs,
    required this.branchSalesEggs,
    required this.revenue,
    required this.profit,
    required this.recentActivity,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalStockValue: json["total_stock_value"] ?? 0,
      totalStockEggs: json["total_stock_eggs"] ?? 0,
      inTransit: json["in_transit"] ?? 0,
      incomingStockEggs: json["incoming_stock_eggs"] ?? 0,
      dispatched: json["dispatched"] ?? 0,
      dispatchedStockEggs: json["dispatched_stock_eggs"] ?? 0,
      branchSalesEggs: json["branch_sales_eggs"] ?? 0,
      revenue: json["revenue"].toString(),
      profit: json["profit"].toString(),
      recentActivity: json["recent_activity"] ?? [],
    );
  }
}