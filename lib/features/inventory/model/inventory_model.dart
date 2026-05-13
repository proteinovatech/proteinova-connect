class InventoryModel {

  final int? branchId;
  final String? branchName;
  final Cards cards;

  final List<Shipment> shipments;

  final List<RecentActivity> recentActivity;

  InventoryModel({
    required this.branchId,
    required this.branchName,
    required this.cards,
    required this.shipments,
    required this.recentActivity,
  });

 factory InventoryModel.fromJson(
  Map<String, dynamic> json,
) {

  return InventoryModel(

    branchId:
        json["branch_id"],

    branchName:
        json["branch_name"],

    cards: Cards.fromJson(
      json["cards"] ?? {},
    ),

    shipments:

        json["shipments"] != null

            ? (json["shipments"] as List)

                .map(
                  (e) => Shipment.fromJson(e),
                )
                .toList()

            : [],

    recentActivity:

        json["recent_activity"] != null

            ? (json["recent_activity"] as List)

                .map(
                  (e) => RecentActivity.fromJson(e),
                )
                .toList()

            : [],
  );
}}

class Cards {

  final int expectedToday;

  final int readyForUnloading;

  final int delayedInTransit;

  final int totalTraysInTransit;

  final int totalEggsInTransit;

  Cards({
    required this.expectedToday,
    required this.readyForUnloading,
    required this.delayedInTransit,
    required this.totalTraysInTransit,
    required this.totalEggsInTransit,
  });

  factory Cards.fromJson(
    Map<String, dynamic> json,
  ) {
    return Cards(

      expectedToday:
          json["expected_today"] ?? 0,

      readyForUnloading:
          json["ready_for_unloading"] ?? 0,

      delayedInTransit:
          json["delayed_in_transit"] ?? 0,

      totalTraysInTransit:
          json["total_trays_in_transit"] ?? 0,

      totalEggsInTransit:
          json["total_eggs_in_transit"] ?? 0,
    );
  }
}

class Shipment {

  final int? dispatchId;

  final String? dispatchCode;

  final String? expectedArrival;

  final String? dispatchDate;

  final String? arrivalDate;

  final String? supplierOrFrom;

  final String? vehicleDriver;

  final String? productSummary;

  final int? totalTrays;

  final int? totalEggs;

  final String? status;

  Shipment({

    this.dispatchId,

    this.dispatchCode,

    this.expectedArrival,

    this.dispatchDate,

    this.arrivalDate,

    this.supplierOrFrom,

    this.vehicleDriver,

    this.productSummary,

    this.totalTrays,

    this.totalEggs,

    this.status,
  });

  factory Shipment.fromJson(
    Map<String, dynamic> json,
  ) {

    return Shipment(

      dispatchId:
          json["dispatch_id"],

      dispatchCode:
          json["dispatch_code"],

      expectedArrival:
          json["expected_arrival"],

      dispatchDate:
          json["dispatch_date"],

      arrivalDate:
          json["arrival_date"],

      supplierOrFrom:
          json["supplier_or_from"],

      vehicleDriver:
          json["vehicle_driver"],

      productSummary:
          json["product_summary"],

      totalTrays:
          json["total_trays"],

      totalEggs:
          json["total_eggs"],

      status:
          json["status"],
    );
  }
}
class RecentActivity {

  final String actorName;

  final String activityType;

  final String activity;

  final String createdAt;

  RecentActivity({

    required this.actorName,

    required this.activityType,

    required this.activity,

    required this.createdAt,
  });

  factory RecentActivity.fromJson(
    Map<String, dynamic> json,
  ) {

    return RecentActivity(

      actorName:
          json["actor_name"] ?? "",

      activityType:
          json["activity_type"] ?? "",

      activity:
          json["activity"] ?? "",

      createdAt:
          json["created_at"] ?? "",
    );
  }
}