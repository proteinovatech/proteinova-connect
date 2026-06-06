class DailyClosingAdminModel {
  final String status;
  final String notes;
  final DailyClosingCashSummary? cashSummary;
  final DailyClosingStockSummary? stockSummary;
  final DailyClosingSales? sales;
  final DailyClosingExpenses? expenses;
  final DailyClosingOnlineSummary? onlineSummary;
  final DailyClosingSalesSummary? salesSummary;
  final DailyClosingExpenseSummary? expenseSummary;
  final DailyClosingStockValue? closingStockValue;
  final DailyClosingTodaysSummary? todaysSummary;

  DailyClosingAdminModel({
    required this.status,
    required this.notes,
    this.cashSummary,
    this.stockSummary,
    this.sales,
    this.expenses,
    this.onlineSummary,
    this.salesSummary,
    this.expenseSummary,
    this.closingStockValue,
    this.todaysSummary,
  });

  factory DailyClosingAdminModel.fromJson(Map<String, dynamic> json) {
    return DailyClosingAdminModel(
      status: json['status']?.toString() ?? 'OPEN',
      notes: json['notes']?.toString() ?? '',
      cashSummary: json['cash_summary'] != null ? DailyClosingCashSummary.fromJson(json['cash_summary']) : null,
      stockSummary: json['stock_summary'] != null ? DailyClosingStockSummary.fromJson(json['stock_summary']) : null,
      sales: json['sales'] != null ? DailyClosingSales.fromJson(json['sales']) : null,
      expenses: json['expenses'] != null ? DailyClosingExpenses.fromJson(json['expenses']) : null,
      onlineSummary: json['online_summary'] != null ? DailyClosingOnlineSummary.fromJson(json['online_summary']) : null,
      salesSummary: json['sales_summary'] != null ? DailyClosingSalesSummary.fromJson(json['sales_summary']) : null,
      expenseSummary: json['expense_summary'] != null ? DailyClosingExpenseSummary.fromJson(json['expense_summary']) : null,
      closingStockValue: json['closing_stock_value'] != null ? DailyClosingStockValue.fromJson(json['closing_stock_value']) : null,
      todaysSummary: json['todays_summary'] != null ? DailyClosingTodaysSummary.fromJson(json['todays_summary']) : null,
    );
  }
}

class DailyClosingCashSummary {
  final num counted;

  DailyClosingCashSummary({required this.counted});

  factory DailyClosingCashSummary.fromJson(Map<String, dynamic> json) {
    return DailyClosingCashSummary(
      counted: num.tryParse(json['counted']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingStockSummary {
  final num totalOpening;
  final num totalReceived;
  final num totalSold;
  final num totalDamaged;
  final num totalClosing;

  final num totalOpeningEggs;
  final num totalReceivedEggs;
  final num totalSoldEggs;
  final num totalDamagedEggs;
  final num totalClosingEggs;

  DailyClosingStockSummary({
    required this.totalOpening,
    required this.totalReceived,
    required this.totalSold,
    required this.totalDamaged,
    required this.totalClosing,
    required this.totalOpeningEggs,
    required this.totalReceivedEggs,
    required this.totalSoldEggs,
    required this.totalDamagedEggs,
    required this.totalClosingEggs,
  });

  factory DailyClosingStockSummary.fromJson(Map<String, dynamic> json) {
    return DailyClosingStockSummary(
      totalOpening: num.tryParse(json['total_opening']?.toString() ?? '') ?? 0,
      totalReceived: num.tryParse(json['total_received']?.toString() ?? '') ?? 0,
      totalSold: num.tryParse(json['total_sold']?.toString() ?? '') ?? 0,
      totalDamaged: num.tryParse(json['total_damaged']?.toString() ?? '') ?? 0,
      totalClosing: num.tryParse(json['total_closing']?.toString() ?? '') ?? 0,
      totalOpeningEggs: num.tryParse(json['total_opening_eggs']?.toString() ?? '') ?? 0,
      totalReceivedEggs: num.tryParse(json['total_received_eggs']?.toString() ?? '') ?? 0,
      totalSoldEggs: num.tryParse(json['total_sold_eggs']?.toString() ?? '') ?? 0,
      totalDamagedEggs: num.tryParse(json['total_damaged_eggs']?.toString() ?? '') ?? 0,
      totalClosingEggs: num.tryParse(json['total_closing_eggs']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingSales {
  final num cash;
  final num upi;
  final num card;
  final num total;

  DailyClosingSales({
    required this.cash,
    required this.upi,
    required this.card,
    required this.total,
  });

  factory DailyClosingSales.fromJson(Map<String, dynamic> json) {
    return DailyClosingSales(
      cash: num.tryParse(json['cash']?.toString() ?? '') ?? 0,
      upi: num.tryParse(json['upi']?.toString() ?? '') ?? 0,
      card: num.tryParse(json['card']?.toString() ?? '') ?? 0,
      total: num.tryParse(json['total']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingExpenses {
  final num cash;
  final num upi;
  final num card;
  final num total;

  DailyClosingExpenses({
    required this.cash,
    required this.upi,
    required this.card,
    required this.total,
  });

  factory DailyClosingExpenses.fromJson(Map<String, dynamic> json) {
    return DailyClosingExpenses(
      cash: num.tryParse(json['cash']?.toString() ?? '') ?? 0,
      upi: num.tryParse(json['upi']?.toString() ?? '') ?? 0,
      card: num.tryParse(json['card']?.toString() ?? '') ?? 0,
      total: num.tryParse(json['total']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingOnlineSummary {
  final DailyClosingOnlineItem upi;
  final DailyClosingOnlineItem card;
  final num totalCollection;

  DailyClosingOnlineSummary({
    required this.upi,
    required this.card,
    required this.totalCollection,
  });

  factory DailyClosingOnlineSummary.fromJson(Map<String, dynamic> json) {
    return DailyClosingOnlineSummary(
      upi: DailyClosingOnlineItem.fromJson(json['upi'] ?? {}),
      card: DailyClosingOnlineItem.fromJson(json['card'] ?? {}),
      totalCollection: num.tryParse(json['total_collection']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingOnlineItem {
  final num sales;
  final num expense;
  final num closing;

  DailyClosingOnlineItem({
    required this.sales,
    required this.expense,
    required this.closing,
  });

  factory DailyClosingOnlineItem.fromJson(Map<String, dynamic> json) {
    return DailyClosingOnlineItem(
      sales: num.tryParse(json['sales']?.toString() ?? '') ?? 0,
      expense: num.tryParse(json['expense']?.toString() ?? '') ?? 0,
      closing: num.tryParse(json['closing']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingSalesSummary {
  final num total;
  final num cash;
  final num upi;

  DailyClosingSalesSummary({
    required this.total,
    required this.cash,
    required this.upi,
  });

  factory DailyClosingSalesSummary.fromJson(Map<String, dynamic> json) {
    return DailyClosingSalesSummary(
      total: num.tryParse(json['total']?.toString() ?? '') ?? 0,
      cash: num.tryParse(json['cash']?.toString() ?? '') ?? 0,
      upi: num.tryParse(json['upi']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingExpenseSummary {
  final num total;
  final num cash;
  final num upi;

  DailyClosingExpenseSummary({
    required this.total,
    required this.cash,
    required this.upi,
  });

  factory DailyClosingExpenseSummary.fromJson(Map<String, dynamic> json) {
    return DailyClosingExpenseSummary(
      total: num.tryParse(json['total']?.toString() ?? '') ?? 0,
      cash: num.tryParse(json['cash']?.toString() ?? '') ?? 0,
      upi: num.tryParse(json['upi']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingStockValue {
  final num eggs;
  final num plastic;
  final num paper;
  final num empty;
  final num total;

  DailyClosingStockValue({
    required this.eggs,
    required this.plastic,
    required this.paper,
    required this.empty,
    required this.total,
  });

  factory DailyClosingStockValue.fromJson(Map<String, dynamic> json) {
    return DailyClosingStockValue(
      eggs: num.tryParse(json['eggs']?.toString() ?? '') ?? 0,
      plastic: num.tryParse(json['plastic']?.toString() ?? '') ?? 0,
      paper: num.tryParse(json['paper']?.toString() ?? '') ?? 0,
      empty: num.tryParse(json['empty']?.toString() ?? '') ?? 0,
      total: num.tryParse(json['total']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingTodaysSummary {
  final num openingStockValue;
  final num receivedStockValue;
  final num soldStockValue;
  final num damagedStockValue;
  final num closingStockValue;

  DailyClosingTodaysSummary({
    required this.openingStockValue,
    required this.receivedStockValue,
    required this.soldStockValue,
    required this.damagedStockValue,
    required this.closingStockValue,
  });

  factory DailyClosingTodaysSummary.fromJson(Map<String, dynamic> json) {
    return DailyClosingTodaysSummary(
      openingStockValue: num.tryParse(json['opening_stock_value']?.toString() ?? '') ?? 0,
      receivedStockValue: num.tryParse(json['received_stock_value']?.toString() ?? '') ?? 0,
      soldStockValue: num.tryParse(json['sold_stock_value']?.toString() ?? '') ?? 0,
      damagedStockValue: num.tryParse(json['damaged_stock_value']?.toString() ?? '') ?? 0,
      closingStockValue: num.tryParse(json['closing_stock_value']?.toString() ?? '') ?? 0,
    );
  }
}
