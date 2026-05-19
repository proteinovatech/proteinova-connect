class DashboardModel {
  final num totalStockValue;
  final num totalStockEggs;
  final num inTransit;
  final num incomingStockEggs;
  final num dispatched;
  final num dispatchedStockEggs;
  final num branchSalesEggs;
  final String revenue;
  final String branchRevenue;
  final String profit;
  final List<dynamic> recentActivity;
  final Map<String, dynamic> breakdowns;

  DashboardModel({
    required this.totalStockValue,
    required this.totalStockEggs,
    required this.inTransit,
    required this.incomingStockEggs,
    required this.dispatched,
    required this.dispatchedStockEggs,
    required this.branchSalesEggs,
    required this.revenue,
    required this.branchRevenue,
    required this.profit,
    required this.recentActivity,
    required this.breakdowns,
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
      revenue: json["revenue"]?.toString() ?? "0",
      branchRevenue: json["branch_revenue"]?.toString() ?? "0",
      profit: json["profit"]?.toString() ?? "0",
      recentActivity: json["recent_activity"] ?? [],
      breakdowns: json["breakdowns"] is Map ? Map<String, dynamic>.from(json["breakdowns"]) : {},
    );
  }
}