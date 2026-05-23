class DailyClosingModel {
  final String status;
  final String branchName;
  final StockSummaryData stockSummary;
  final CashSummaryData cashSummary;
  final OnlineSummaryData onlineSummary;
  final SummarySection salesSummary;
  final SummarySection expenseSummary;
  final ClosingStockValue closingStockValue;
  final TodaysSummary todaysSummary;
  final String notes;
  final SalesExpenseDetail sales;
  final SalesExpenseDetail expenses;

  DailyClosingModel({
    required this.status,
    required this.branchName,
    required this.stockSummary,
    required this.cashSummary,
    required this.onlineSummary,
    required this.salesSummary,
    required this.expenseSummary,
    required this.closingStockValue,
    required this.todaysSummary,
    required this.notes,
    required this.sales,
    required this.expenses,
  });

  factory DailyClosingModel.fromJson(Map<String, dynamic> json) {
    return DailyClosingModel(
      status: json['status'] ?? "PENDING",
      branchName: json['branch_name'] ?? "",
      stockSummary: StockSummaryData.fromJson(json['stock_summary'] ?? {}),
      cashSummary: CashSummaryData.fromJson(json['cash_summary'] ?? {}),
      onlineSummary: OnlineSummaryData.fromJson(json['online_summary'] ?? {}),
      salesSummary: SummarySection.fromJson(json['sales_summary'] ?? {}),
      expenseSummary: SummarySection.fromJson(json['expense_summary'] ?? {}),
      closingStockValue: ClosingStockValue.fromJson(json['closing_stock_value'] ?? {}),
      todaysSummary: TodaysSummary.fromJson(json['todays_summary'] ?? {}),
      notes: json['notes'] ?? "",
      sales: SalesExpenseDetail.fromJson(json['sales'] ?? {}),
      expenses: SalesExpenseDetail.fromJson(json['expenses'] ?? {}),
    );
  }
}

class SalesExpenseDetail {
  final num total;
  final num cash;
  final num upi;
  final num card;
  final num online;

  SalesExpenseDetail({
    required this.total,
    required this.cash,
    required this.upi,
    required this.card,
    required this.online,
  });

  factory SalesExpenseDetail.fromJson(Map<String, dynamic> json) {
    return SalesExpenseDetail(
      total: json['total'] ?? 0,
      cash: json['cash'] ?? 0,
      upi: json['upi'] ?? 0,
      card: json['card'] ?? 0,
      online: json['online'] ?? 0,
    );
  }
}


class StockSummaryData {
  final num totalOpening;
  final num totalReceived;
  final num totalSold;
  final num totalClosing;
  final num totalOpeningEggs;
  final num totalReceivedEggs;
  final num totalSoldEggs;
  final num totalClosingEggs;

  StockSummaryData({
    required this.totalOpening,
    required this.totalReceived,
    required this.totalSold,
    required this.totalClosing,
    required this.totalOpeningEggs,
    required this.totalReceivedEggs,
    required this.totalSoldEggs,
    required this.totalClosingEggs,
  });

  factory StockSummaryData.fromJson(Map<String, dynamic> json) {
    return StockSummaryData(
      totalOpening: json['total_opening'] ?? 0,
      totalReceived: json['total_received'] ?? 0,
      totalSold: json['total_sold'] ?? 0,
      totalClosing: json['total_closing'] ?? 0,
      totalOpeningEggs: json['total_opening_eggs'] ?? 0,
      totalReceivedEggs: json['total_received_eggs'] ?? 0,
      totalSoldEggs: json['total_sold_eggs'] ?? 0,
      totalClosingEggs: json['total_closing_eggs'] ?? 0,
    );
  }
}

class CashSummaryData {
  final num closing;
  final num counted;

  CashSummaryData({required this.closing, required this.counted});

  factory CashSummaryData.fromJson(Map<String, dynamic> json) {
    return CashSummaryData(
      closing: json['closing'] ?? 0,
      counted: json['counted'] ?? 0,
    );
  }
}

class OnlineSummaryData {
  final OnlineSubSection upi;
  final OnlineSubSection card;
  final num totalCollection;

  OnlineSummaryData({
    required this.upi,
    required this.card,
    required this.totalCollection,
  });

  factory OnlineSummaryData.fromJson(Map<String, dynamic> json) {
    return OnlineSummaryData(
      upi: OnlineSubSection.fromJson(json['upi'] ?? {}),
      card: OnlineSubSection.fromJson(json['card'] ?? {}),
      totalCollection: json['total_collection'] ?? 0,
    );
  }
}

class OnlineSubSection {
  final num sales;
  final num expense;
  final num closing;

  OnlineSubSection({
    required this.sales,
    required this.expense,
    required this.closing,
  });

  factory OnlineSubSection.fromJson(Map<String, dynamic> json) {
    return OnlineSubSection(
      sales: json['sales'] ?? 0,
      expense: json['expense'] ?? 0,
      closing: json['closing'] ?? 0,
    );
  }
}

class SummarySection {
  final num total;
  final num cash;
  final num upi;

  SummarySection({
    required this.total,
    required this.cash,
    required this.upi,
  });

  factory SummarySection.fromJson(Map<String, dynamic> json) {
    return SummarySection(
      total: json['total'] ?? 0,
      cash: json['cash'] ?? 0,
      upi: json['upi'] ?? 0,
    );
  }
}

class ClosingStockValue {
  final num eggs;
  final num plastic;
  final num paper;
  final num empty;
  final num total;

  ClosingStockValue({
    required this.eggs,
    required this.plastic,
    required this.paper,
    required this.empty,
    required this.total,
  });

  factory ClosingStockValue.fromJson(Map<String, dynamic> json) {
    return ClosingStockValue(
      eggs: json['eggs'] ?? 0,
      plastic: json['plastic'] ?? 0,
      paper: json['paper'] ?? 0,
      empty: json['empty'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class TodaysSummary {
  final num openingStockValue;
  final num receivedStockValue;
  final num totalSales;
  final num totalExpenses;
  final num finalValue;

  TodaysSummary({
    required this.openingStockValue,
    required this.receivedStockValue,
    required this.totalSales,
    required this.totalExpenses,
    required this.finalValue,
  });

  factory TodaysSummary.fromJson(Map<String, dynamic> json) {
    return TodaysSummary(
      openingStockValue: json['opening_stock_value'] ?? 0,
      receivedStockValue: json['received_stock_value'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      totalExpenses: json['total_expenses'] ?? 0,
      finalValue: json['final_value'] ?? 0,
    );
  }
}
