class TrayReturnModel {
  final Filters filters;
  final Cards cards;
  final RefundCreditSummary refundCreditSummary;
  final List<TrayData> data;

  TrayReturnModel({
    required this.filters,
    required this.cards,
    required this.refundCreditSummary,
    required this.data,
  });

  factory TrayReturnModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrayReturnModel(
      filters: Filters.fromJson(
        json["filters"] ?? {},
      ),

      cards: Cards.fromJson(
        json["cards"] ?? {},
      ),

      refundCreditSummary:
          RefundCreditSummary.fromJson(
        json["refund_credit_summary"] ?? {},
      ),

      data: (json["data"] is List
              ? json["data"] as List
              : (json["data"] is Map ? json["data"]["records"] as List? : null) ??
                  [])
          .map(
            (e) => TrayData.fromJson(e),
          )
          .toList(),
    );
  }
}

class Filters {
  final int branchId;
  final String date;
  final dynamic month;
  final int limit;
  final int offset;

  Filters({
    required this.branchId,
    required this.date,
    this.month,
    required this.limit,
    required this.offset,
  });

  factory Filters.fromJson(
    Map<String, dynamic> json,
  ) {
    return Filters(
      branchId: json["branch_id"] ?? 0,
      date: json["date"] ?? "",
      month: json["month"],
      limit: json["limit"] ?? 0,
      offset: json["offset"] ?? 0,
    );
  }
}

class Cards {
  final num refundCredit;
  final num damagedTrays;
  final num totalReturnedThisMonth;
  final num goodTrays;

  Cards({
    required this.refundCredit,
    required this.damagedTrays,
    required this.totalReturnedThisMonth,
    required this.goodTrays,
  });

  factory Cards.fromJson(
    Map<String, dynamic> json,
  ) {
    return Cards(
      refundCredit:
          json["refund_credit"] ?? 0,
      damagedTrays:
          json["damaged_trays"] ?? 0,
      totalReturnedThisMonth:
          json["total_returned_this_month"] ??
              0,
      goodTrays:
          json["good_trays"] ?? 0,
    );
  }
}

class RefundCreditSummary {
  final num totalRefund;
  final num pendingRefund;
  final num totalCredit;
  final num pendingCredit;

  RefundCreditSummary({
    required this.totalRefund,
    required this.pendingRefund,
    required this.totalCredit,
    required this.pendingCredit,
  });

  factory RefundCreditSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return RefundCreditSummary(
      totalRefund:
          json["total_refund"] ?? 0,
      pendingRefund:
          json["pending_refund"] ?? 0,
      totalCredit:
          json["total_credit"] ?? 0,
      pendingCredit:
          json["pending_credit"] ?? 0,
    );
  }
}

class TrayData {
  final String date;
  final String from;
  final String trayType;
  final String qty;
  final String condition;
  final String reason;
  final dynamic price;

  TrayData({
    required this.date,
    required this.from,
    required this.trayType,
    required this.qty,
    required this.condition,
    required this.reason,
    required this.price,
  });

  factory TrayData.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrayData(
      date: json["return_date"] ?? json["date"] ?? "",
      from: json["return_from_name"] ?? json["from"] ?? "",
      trayType:
          json["tray_type"] ?? "",
      qty: (json["quantity"] ?? json["qty"] ?? 0).toString(),
      condition:
          json["condition"] ?? "",
      reason: json["reason"] ?? "",
      price: json["amount"] ?? json["price"] ?? 0,
    );
  }
}