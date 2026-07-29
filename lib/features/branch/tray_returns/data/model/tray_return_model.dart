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
  final int openingTrays;
  final int incomingTrays;
  final int returnedTrays;
  final int closingTrays;
  final int emptyTrays;

  final int openingEmptyPlastic;
  final int openingEmptyPaper;
  final int openingFilledPlastic;
  final int openingFilledPaper;

  final int inEmptyPlastic;
  final int inEmptyPaper;
  final int inFilledPlastic;
  final int inFilledPaper;

  final int returnedPlastic;
  final int returnedPaper;

  final int emptyPlastic;
  final int emptyPaper;

  final int filledPlastic;
  final int filledPaper;

  Cards({
    required this.openingTrays,
    required this.incomingTrays,
    required this.returnedTrays,
    required this.closingTrays,
    required this.emptyTrays,
    required this.openingEmptyPlastic,
    required this.openingEmptyPaper,
    required this.openingFilledPlastic,
    required this.openingFilledPaper,
    required this.inEmptyPlastic,
    required this.inEmptyPaper,
    required this.inFilledPlastic,
    required this.inFilledPaper,
    required this.returnedPlastic,
    required this.returnedPaper,
    required this.emptyPlastic,
    required this.emptyPaper,
    required this.filledPlastic,
    required this.filledPaper,
  });

  factory Cards.fromJson(Map<String, dynamic> json) {
    return Cards(
      openingTrays: json["opening_trays"] ?? 0,
      incomingTrays: json["incoming_trays"] ?? 0,
      returnedTrays: json["returned_trays"] ?? 0,
      closingTrays: json["closing_trays"] ?? 0,
      emptyTrays: json["empty_trays"] ?? 0,

      openingEmptyPlastic: json["opening_empty_plastic"] ?? 0,
      openingEmptyPaper: json["opening_empty_paper"] ?? 0,
      openingFilledPlastic: json["opening_filled_plastic"] ?? 0,
      openingFilledPaper: json["opening_filled_paper"] ?? 0,

      inEmptyPlastic: json["in_empty_plastic"] ?? 0,
      inEmptyPaper: json["in_empty_paper"] ?? 0,
      inFilledPlastic: json["in_filled_plastic"] ?? 0,
      inFilledPaper: json["in_filled_paper"] ?? 0,

      returnedPlastic: json["returned_plastic"] ?? 0,
      returnedPaper: json["returned_paper"] ?? 0,

      emptyPlastic: json["closing_empty_plastic"] ?? json["empty_plastic"] ?? 0,
      emptyPaper: json["closing_empty_paper"] ?? json["empty_paper"] ?? 0,

      filledPlastic: json["closing_filled_plastic"] ?? json["filled_plastic"] ?? 0,
      filledPaper: json["closing_filled_paper"] ?? json["filled_paper"] ?? 0,
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