class DashboardModel {
  final int? branchId;
  final String? branchName;
  final String? closingStatus;
  final Cards cards;
  final List<ActiveOffer> activeOffers;
  final List<DailySalesVolume> dailySalesVolume;
  final List<RecentActivity> recentActivity;
  final List<LowStockAlert> lowStockAlerts;
  final List<StockSummary> stockSummary;
  final List<IncomingShipment> incomingShipments;
  final List<DamagedDetail> damagedDetails;
  final List<TodayExpenseList> todayExpensesList;

  DashboardModel({
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

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    print(json["low_stock_alerts"]);

    return DashboardModel(
      branchId: json["branch_id"],
      branchName: json["branch_name"],
      closingStatus: json["closing_status"],
      cards: Cards.fromJson(json["cards"] ?? {}),
      activeOffers: json["active_offers"] != null
          ? (json["active_offers"] as List)
              .map((e) => ActiveOffer.fromJson(e))
              .toList()
          : [],
      dailySalesVolume: json["daily_sales_volume"] != null
          ? (json["daily_sales_volume"] as List)
              .map((e) => DailySalesVolume.fromJson(e))
              .toList()
          : [],
      recentActivity: json["recent_activity"] != null
          ? (json["recent_activity"] as List)
              .map((e) => RecentActivity.fromJson(e))
              .toList()
          : [],
      lowStockAlerts: json["low_stock_alerts"] != null
          ? (json["low_stock_alerts"] as List)
              .map((e) => LowStockAlert.fromJson(e))
              .toList()
          : [],
      stockSummary: json["stock_summary"] != null
          ? (json["stock_summary"] as List)
              .map((e) => StockSummary.fromJson(e))
              .toList()
          : [],
      incomingShipments: json["incoming_shipments"] != null
          ? (json["incoming_shipments"] as List)
              .map((e) => IncomingShipment.fromJson(e))
              .toList()
          : [],
      damagedDetails: json["damaged_details"] != null
          ? (json["damaged_details"] as List)
              .map((e) => DamagedDetail.fromJson(e))
              .toList()
          : [],
      todayExpensesList: json["today_expenses_list"] != null
          ? (json["today_expenses_list"] as List)
              .map((e) => TodayExpenseList.fromJson(e))
              .toList()
          : [],
    );
  }
}

class LowStockAlert {
  final String title;
  final String subtitle;
  final String stock;

  LowStockAlert({
    required this.title,
    required this.subtitle,
    required this.stock,
  });

  factory LowStockAlert.fromJson(Map<String, dynamic> json) {
    return LowStockAlert(
      title: json["egg_category_grade"]?.toString() ?? "",
      subtitle: "Threshold: ${json["threshold"]?.toString() ?? "0"}",
      stock: "${json["trays"]?.toString() ?? "0"} Trays",
    );
  }
}

class Cards {
  final int openingStocks;
  final int incomingStockInTransit;
  final int damagedStock;
  final double salesToday;
  final double todayExpense;
  final int todayTraySold;
  final int closingStock;

  Cards({
    required this.openingStocks,
    required this.incomingStockInTransit,
    required this.damagedStock,
    required this.salesToday,
    required this.todayExpense,
    required this.todayTraySold,
    required this.closingStock,
  });

  factory Cards.fromJson(Map<String, dynamic> json) {
    return Cards(
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

class ActiveOffer {
  final String title;
  final String condition;

  ActiveOffer({
    required this.title,
    required this.condition,
  });

  factory ActiveOffer.fromJson(Map<String, dynamic> json) {
    return ActiveOffer(
      title: json["title"] ?? "",
      condition: json["condition"] ?? "",
    );
  }
}

class DailySalesVolume {
  final String saleDate;
  final double retailSalesUnits;
  final double wholesaleSalesUnits;

  DailySalesVolume({
    required this.saleDate,
    required this.retailSalesUnits,
    required this.wholesaleSalesUnits,
  });

  factory DailySalesVolume.fromJson(Map<String, dynamic> json) {
    return DailySalesVolume(
      saleDate: json["sale_date"] ?? "",
      retailSalesUnits: _toDouble(json["retail_sales_units"]),
      wholesaleSalesUnits: _toDouble(json["wholesale_sales_units"]),
    );
  }
}

class RecentActivity {
  final String title;
  final String description;
  final String time;
  final String tag;
  final double? amount;

  RecentActivity({
    required this.title,
    required this.description,
    required this.time,
    required this.tag,
    this.amount,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      title: json["title"] ?? json["actor_name"] ?? "",
      description: json["description"] ?? json["activity"] ?? "",
      time: json["time"] ?? json["created_at"] ?? "",
      tag: json["tag"] ?? json["activity_type"] ?? "",
      amount: json["amount"] != null ? _toDouble(json["amount"]) : null,
    );
  }
}

class StockSummary {
  final String eggCategoryGrade;
  final String trayGroup;
  final int trays;
  final int eggs;

  StockSummary({
    required this.eggCategoryGrade,
    required this.trayGroup,
    required this.trays,
    required this.eggs,
  });

  factory StockSummary.fromJson(Map<String, dynamic> json) {
    return StockSummary(
      eggCategoryGrade: json["egg_category_grade"]?.toString() ?? "",
      trayGroup: json["tray_group"]?.toString() ?? "",
      trays: _toInt(json["trays"]),
      eggs: _toInt(json["eggs"]),
    );
  }
}

class IncomingShipment {
  final int id;
  final int totalTrays;
  final String? arrivalDate;

  IncomingShipment({
    required this.id,
    required this.totalTrays,
    required this.arrivalDate,
  });

  factory IncomingShipment.fromJson(Map<String, dynamic> json) {
    return IncomingShipment(
      id: _toInt(json["id"]),
      totalTrays: _toInt(json["total_trays"]),
      arrivalDate: json["arrival_date"],
    );
  }
}

class DamagedDetail {
  final String eggCategoryGrade;
  final int trays;

  DamagedDetail({
    required this.eggCategoryGrade,
    required this.trays,
  });

  factory DamagedDetail.fromJson(Map<String, dynamic> json) {
    return DamagedDetail(
      eggCategoryGrade: json["egg_category_grade"]?.toString() ?? "",
      trays: _toInt(json["trays"]),
    );
  }
}

class TodayExpenseList {
  final String category;
  final double amount;
  final String? description;

  TodayExpenseList({
    required this.category,
    required this.amount,
    required this.description,
  });

  factory TodayExpenseList.fromJson(Map<String, dynamic> json) {
    return TodayExpenseList(
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