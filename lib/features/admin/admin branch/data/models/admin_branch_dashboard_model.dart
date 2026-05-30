class AdminBranchDashboardModel {
  final int? branchId;
  final String? branchName;
  final String? closingStatus;
  final AdminBranchCards cards;
  final List<AdminBranchActiveOffer> activeOffers;
  final List<AdminBranchDailySalesVolume> dailySalesVolume;
  final List<AdminBranchRecentActivity> recentActivity;
  final List<AdminBranchLowStockAlert> lowStockAlerts;
  final List<AdminBranchStockSummary> stockSummary;
  final List<AdminBranchIncomingShipment> incomingShipments;
  final List<AdminBranchDamagedDetail> damagedDetails;
  final List<AdminBranchTodayExpenseList> todayExpensesList;

  AdminBranchDashboardModel({
    required this.branchId,
    required this.branchName,
    required this.closingStatus,
    required this.cards,
    required this.activeOffers,
    required this.dailySalesVolume,
    required this.recentActivity,
    required this.lowStockAlerts,
    required this.stockSummary,
    required this.incomingShipments,
    required this.damagedDetails,
    required this.todayExpensesList,
  });

  factory AdminBranchDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminBranchDashboardModel(
      branchId: json["branch_id"],
      branchName: json["branch_name"],
      closingStatus: json["closing_status"],
      cards: AdminBranchCards.fromJson(json["cards"] ?? {}),
      activeOffers: json["active_offers"] != null
          ? (json["active_offers"] as List)
              .map((e) => AdminBranchActiveOffer.fromJson(e))
              .toList()
          : [],
      dailySalesVolume: json["daily_sales_volume"] != null
          ? (json["daily_sales_volume"] as List)
              .map((e) => AdminBranchDailySalesVolume.fromJson(e))
              .toList()
          : [],
      recentActivity: json["recent_activity"] != null
          ? (json["recent_activity"] as List)
              .map((e) => AdminBranchRecentActivity.fromJson(e))
              .toList()
          : [],
      lowStockAlerts: json["low_stock_alerts"] != null
          ? (json["low_stock_alerts"] as List)
              .map((e) => AdminBranchLowStockAlert.fromJson(e))
              .toList()
          : [],
      stockSummary: json["stock_summary"] != null
          ? (json["stock_summary"] as List)
              .map((e) => AdminBranchStockSummary.fromJson(e))
              .toList()
          : [],
      incomingShipments: json["incoming_shipments"] != null
          ? (json["incoming_shipments"] as List)
              .map((e) => AdminBranchIncomingShipment.fromJson(e))
              .toList()
          : [],
      damagedDetails: json["damaged_details"] != null
          ? (json["damaged_details"] as List)
              .map((e) => AdminBranchDamagedDetail.fromJson(e))
              .toList()
          : [],
      todayExpensesList: json["today_expenses_list"] != null
          ? (json["today_expenses_list"] as List)
              .map((e) => AdminBranchTodayExpenseList.fromJson(e))
              .toList()
          : [],
    );
  }
}

class AdminBranchLowStockAlert {
  final String title;
  final String subtitle;
  final String stock;

  AdminBranchLowStockAlert({
    required this.title,
    required this.subtitle,
    required this.stock,
  });

  factory AdminBranchLowStockAlert.fromJson(Map<String, dynamic> json) {
    return AdminBranchLowStockAlert(
      title: json["egg_category_grade"]?.toString() ?? "",
      subtitle: "Threshold: ${json["threshold"]?.toString() ?? "0"}",
      stock: "${json["trays"]?.toString() ?? "0"} Trays",
    );
  }
}

class AdminBranchCards {
  final int openingStocks;
  final int incomingStockInTransit;
  final int damagedStock;
  final double salesToday;
  final double todayExpense;
  final int todayTraySold;
  final int closingStock;

  AdminBranchCards({
    required this.openingStocks,
    required this.incomingStockInTransit,
    required this.damagedStock,
    required this.salesToday,
    required this.todayExpense,
    required this.todayTraySold,
    required this.closingStock,
  });

  factory AdminBranchCards.fromJson(Map<String, dynamic> json) {
    return AdminBranchCards(
      openingStocks: _toInt(json["opening_stocks"]),
      incomingStockInTransit: _toInt(json["incoming_stock_in_transit"]),
      damagedStock: _toInt(json["damaged_stock"]),
      salesToday: _toDouble(json["sales_today"]),
      todayExpense: _toDouble(json["today_expense"]),
      todayTraySold: _toInt(json["today_tray_sold"]),
      closingStock: _toInt(json["closing_stock"]),
    );
  }
}

class AdminBranchActiveOffer {
  final String title;
  final String condition;

  AdminBranchActiveOffer({
    required this.title,
    required this.condition,
  });

  factory AdminBranchActiveOffer.fromJson(Map<String, dynamic> json) {
    return AdminBranchActiveOffer(
      title: json["title"] ?? "",
      condition: json["condition"] ?? "",
    );
  }
}

class AdminBranchDailySalesVolume {
  final String saleDate;
  final double retailSalesUnits;
  final double wholesaleSalesUnits;

  AdminBranchDailySalesVolume({
    required this.saleDate,
    required this.retailSalesUnits,
    required this.wholesaleSalesUnits,
  });

  factory AdminBranchDailySalesVolume.fromJson(Map<String, dynamic> json) {
    return AdminBranchDailySalesVolume(
      saleDate: json["sale_date"] ?? "",
      retailSalesUnits: _toDouble(json["retail_sales_units"]),
      wholesaleSalesUnits: _toDouble(json["wholesale_sales_units"]),
    );
  }
}

class AdminBranchRecentActivity {
  final String title;
  final String description;
  final String time;
  final String tag;
  final double? amount;

  AdminBranchRecentActivity({
    required this.title,
    required this.description,
    required this.time,
    required this.tag,
    this.amount,
  });

  factory AdminBranchRecentActivity.fromJson(Map<String, dynamic> json) {
    return AdminBranchRecentActivity(
      title: json["title"] ?? json["actor_name"] ?? "",
      description: json["description"] ?? json["activity"] ?? "",
      time: json["time"] ?? json["created_at"] ?? "",
      tag: json["tag"] ?? json["activity_type"] ?? "",
      amount: json["amount"] != null ? _toDouble(json["amount"]) : null,
    );
  }
}

class AdminBranchStockSummary {
  final String eggCategoryGrade;
  final String trayGroup;
  final int trays;
  final int eggs;

  AdminBranchStockSummary({
    required this.eggCategoryGrade,
    required this.trayGroup,
    required this.trays,
    required this.eggs,
  });

  factory AdminBranchStockSummary.fromJson(Map<String, dynamic> json) {
    return AdminBranchStockSummary(
      eggCategoryGrade: json["egg_category_grade"]?.toString() ?? "",
      trayGroup: json["tray_group"]?.toString() ?? "",
      trays: _toInt(json["trays"]),
      eggs: _toInt(json["eggs"]),
    );
  }
}

class AdminBranchIncomingShipment {
  final int id;
  final int totalTrays;
  final String? arrivalDate;

  AdminBranchIncomingShipment({
    required this.id,
    required this.totalTrays,
    required this.arrivalDate,
  });

  factory AdminBranchIncomingShipment.fromJson(Map<String, dynamic> json) {
    return AdminBranchIncomingShipment(
      id: _toInt(json["id"]),
      totalTrays: _toInt(json["total_trays"]),
      arrivalDate: json["arrival_date"],
    );
  }
}

class AdminBranchDamagedDetail {
  final String eggCategoryGrade;
  final int trays;

  AdminBranchDamagedDetail({
    required this.eggCategoryGrade,
    required this.trays,
  });

  factory AdminBranchDamagedDetail.fromJson(Map<String, dynamic> json) {
    return AdminBranchDamagedDetail(
      eggCategoryGrade: json["egg_category_grade"]?.toString() ?? "",
      trays: _toInt(json["trays"]),
    );
  }
}

class AdminBranchTodayExpenseList {
  final String category;
  final double amount;
  final String? description;

  AdminBranchTodayExpenseList({
    required this.category,
    required this.amount,
    required this.description,
  });

  factory AdminBranchTodayExpenseList.fromJson(Map<String, dynamic> json) {
    return AdminBranchTodayExpenseList(
      category: json["category"]?.toString() ?? "",
      amount: _toDouble(json["amount"]),
      description: json["description"],
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  }
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}
