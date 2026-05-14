// class DashboardModel {
//   final int? branchId;
//   final String? branchName;
//   final Cards cards;
//   final List<ActiveOffer> activeOffers;
//   final List<DailySalesVolume> dailySalesVolume;
//   final List<RecentActivity> recentActivity;
  

//   DashboardModel({
//     required this.branchId,
//     required this.branchName,
//     required this.cards,
//     required this.activeOffers,
//     required this.dailySalesVolume,
//     required this.recentActivity,
    
//   });

//   factory DashboardModel.fromJson(Map<String, dynamic> json) {
//     return DashboardModel(
//       branchId: json["branch_id"],
//       branchName: json["branch_name"],
//       cards: Cards.fromJson(json["cards"]),

//       activeOffers: (json["active_offers"] as List)
//           .map((e) => ActiveOffer.fromJson(e))
//           .toList(),

//       dailySalesVolume: (json["daily_sales_volume"] as List)
//           .map((e) => DailySalesVolume.fromJson(e))
//           .toList(),

//     recentActivity:

//         json["recent_activity"] != null

//             ? (json["recent_activity"] as List)

//                 .map(
//                   (e) => RecentActivity.fromJson(e),
//                 )
//                 .toList()

//             : [],
//     );
//   }
// }

// class Cards {
//   final int openingStocks;
//   final int incomingStockInTransit;
//   final int damagedStock;
//   final int salesToday;
//   final int todayExpense;
//   final int todayTraySold;
//   final int closingStock;

//   Cards({
//     required this.openingStocks,
//     required this.incomingStockInTransit,
//     required this.damagedStock,
//     required this.salesToday,
//     required this.todayExpense,
//     required this.todayTraySold,
//     required this.closingStock,
//   });

//   factory Cards.fromJson(Map<String, dynamic> json) {
//     return Cards(
//       openingStocks: json["opening_stocks"] ?? 0,
//       incomingStockInTransit: json["incoming_stock_in_transit"] ?? 0,
//       damagedStock: json["damaged_stock"] ?? 0,
//       salesToday: json["sales_today"] ?? 0,
//       todayExpense: json["today_expense"] ?? 0,
//       todayTraySold: json["today_tray_sold"] ?? 0,
//       closingStock: json["closing_stock"] ?? 0,
//     );
//   }
// }

// class ActiveOffer {
//   final String title;
//   final String condition;

//   ActiveOffer({required this.title, required this.condition});

//   factory ActiveOffer.fromJson(Map<String, dynamic> json) {
//     return ActiveOffer(
//       title: json["title"] ?? "",
//       condition: json["condition"] ?? "",
//     );
//   }
// }

// class DailySalesVolume {
//   final String saleDate;
//   final int retailSalesUnits;
//   final int wholesaleSalesUnits;

//   DailySalesVolume({
//     required this.saleDate,
//     required this.retailSalesUnits,
//     required this.wholesaleSalesUnits,
//   });

//   factory DailySalesVolume.fromJson(Map<String, dynamic> json) {
//     return DailySalesVolume(
//       saleDate: json["sale_date"] ?? "",
//       retailSalesUnits: json["retail_sales_units"] ?? 0,
//       wholesaleSalesUnits: json["wholesale_sales_units"] ?? 0,
//     );
//   }
// }

// class RecentActivity {

//   final String actorName;
//   final String activityType;
//   final String activity;
//   final String createdAt;

//   RecentActivity({
//     required this.actorName,
//     required this.activityType,
//     required this.activity,
//     required this.createdAt,
//   });

//   factory RecentActivity.fromJson(
//     Map<String, dynamic> json,
//   ) {
//     return RecentActivity(

//       actorName:
//           json["actor_name"] ?? "",

//       activityType:
//           json["activity_type"] ?? "",

//       activity:
//           json["activity"] ?? "",

//       createdAt:
//           json["created_at"] ?? "",
//     );
//   }
// }
