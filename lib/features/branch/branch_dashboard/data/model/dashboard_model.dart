class DashboardModel {
  final int? branchId;
  final String? branchName;
  final Cards cards;
  final List<ActiveOffer> activeOffers;
  final List<DailySalesVolume> dailySalesVolume;
  final List<RecentActivity> recentActivity;

  final List<LowStockAlert> lowStockAlerts;

  DashboardModel({
    required this.branchId,
    required this.branchName,
    required this.cards,
    required this.activeOffers,
    required this.dailySalesVolume,
    required this.recentActivity,
    required this.lowStockAlerts,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    print(json["low_stock_alerts"]);

    return DashboardModel(
      branchId: json["branch_id"],
      branchName: json["branch_name"],

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

      subtitle:
          "Threshold: ${json["threshold"]?.toString() ?? "0"}",

      stock:
          "${json["trays"]?.toString() ?? "0"} Trays",
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
      openingStocks:
          (json["opening_stocks"] as num?)?.toInt() ?? 0,

      incomingStockInTransit:
          (json["incoming_stock_in_transit"] as num?)
                  ?.toInt() ??
              0,

      damagedStock:
          (json["damaged_stock"] as num?)?.toInt() ?? 0,

      salesToday:
          (json["sales_today"] as num?)?.toDouble() ?? 0.0,

      todayExpense:
          (json["today_expense"] as num?)?.toDouble() ?? 0.0,

      todayTraySold:
          (json["today_tray_sold"] as num?)?.toInt() ?? 0,

      closingStock:
          (json["closing_stock"] as num?)?.toInt() ?? 0,
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

      retailSalesUnits:
          (json["retail_sales_units"] as num?)
                  ?.toDouble() ??
              0.0,

      wholesaleSalesUnits:
          (json["wholesale_sales_units"] as num?)
                  ?.toDouble() ??
              0.0,
    );
  }
}

class RecentActivity {
  final String title;
  final String description;
  final String time;
  final String tag;

  RecentActivity({
    required this.title,
    required this.description,
    required this.time,
    required this.tag,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      title: json["title"] ?? json["actor_name"] ?? "",

      description:
          json["description"] ?? json["activity"] ?? "",

      time: json["time"] ?? json["created_at"] ?? "",

      tag:
          json["tag"] ?? json["activity_type"] ?? "",
    );
  }
}