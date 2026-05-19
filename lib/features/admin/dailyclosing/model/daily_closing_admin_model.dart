class DailyClosingAdminModel {
  final String status;
  final num openingTrays;
  final num receivedTrays;
  final num soldTrays;
  final num closingTrays;
  final DailyClosingAdminSales sales;
  final DailyClosingAdminExpenses expenses;
  final String notes;

  DailyClosingAdminModel({
    required this.status,
    required this.openingTrays,
    required this.receivedTrays,
    required this.soldTrays,
    required this.closingTrays,
    required this.sales,
    required this.expenses,
    required this.notes,
  });

  factory DailyClosingAdminModel.fromJson(Map<String, dynamic> json) {
    // Nested stock_summary fallback
    final stockSummary = json['stock_summary'] is Map ? json['stock_summary'] : {};

    return DailyClosingAdminModel(
      status: json['status']?.toString() ?? 'OPEN',
      openingTrays: num.tryParse(json['opening_trays']?.toString() ?? stockSummary['total_opening']?.toString() ?? '') ?? 0,
      receivedTrays: num.tryParse(json['received_trays']?.toString() ?? stockSummary['total_received']?.toString() ?? '') ?? 0,
      soldTrays: num.tryParse(json['sold_trays']?.toString() ?? stockSummary['total_sold']?.toString() ?? '') ?? 0,
      closingTrays: num.tryParse(json['closing_trays']?.toString() ?? stockSummary['total_closing']?.toString() ?? '') ?? 0,
      sales: DailyClosingAdminSales.fromJson(json['sales'] ?? json['sales_summary'] ?? {}),
      expenses: DailyClosingAdminExpenses.fromJson(json['expenses'] ?? json['expense_summary'] ?? {}),
      notes: json['notes']?.toString() ?? '',
    );
  }
}

class DailyClosingAdminSales {
  final num cash;
  final num upi;
  final num card;
  final num total;

  DailyClosingAdminSales({
    required this.cash,
    required this.upi,
    required this.card,
    required this.total,
  });

  factory DailyClosingAdminSales.fromJson(Map<String, dynamic> json) {
    return DailyClosingAdminSales(
      cash: num.tryParse(json['cash']?.toString() ?? '') ?? 0,
      upi: num.tryParse(json['upi']?.toString() ?? '') ?? 0,
      card: num.tryParse(json['card']?.toString() ?? '') ?? 0,
      total: num.tryParse(json['total']?.toString() ?? '') ?? 0,
    );
  }
}

class DailyClosingAdminExpenses {
  final num cash;
  final num upi;
  final num total;

  DailyClosingAdminExpenses({
    required this.cash,
    required this.upi,
    required this.total,
  });

  factory DailyClosingAdminExpenses.fromJson(Map<String, dynamic> json) {
    return DailyClosingAdminExpenses(
      cash: num.tryParse(json['cash']?.toString() ?? '') ?? 0,
      upi: num.tryParse(json['upi']?.toString() ?? '') ?? 0,
      total: num.tryParse(json['total']?.toString() ?? '') ?? 0,
    );
  }
}
