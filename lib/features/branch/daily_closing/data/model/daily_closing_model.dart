class DailyClosingModel {
  final int openingTrays;
  final int receivedTrays;
  final int soldTrays;
  final int closingTrays;
  final SalesSummary sales;
  final ExpenseSummary expenses;

  DailyClosingModel({
    required this.openingTrays,
    required this.receivedTrays,
    required this.soldTrays,
    required this.closingTrays,
    required this.sales,
    required this.expenses,
  });

  factory DailyClosingModel.fromJson(Map<String, dynamic> json) {
    return DailyClosingModel(
      openingTrays: json['opening_trays'] ?? 0,
      receivedTrays: json['received_trays'] ?? 0,
      soldTrays: json['sold_trays'] ?? 0,
      closingTrays: json['closing_trays'] ?? 0,
      sales: SalesSummary.fromJson(json['sales'] ?? {}),
      expenses: ExpenseSummary.fromJson(json['expenses'] ?? {}),
    );
  }
}

class SalesSummary {
  final double total;
  final double cash;
  final double upi;
  final double card;
  final double online;

  SalesSummary({
    required this.total,
    required this.cash,
    required this.upi,
    required this.card,
    required this.online,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      cash: double.tryParse(json['cash']?.toString() ?? '0') ?? 0.0,
      upi: double.tryParse(json['upi']?.toString() ?? '0') ?? 0.0,
      card: double.tryParse(json['card']?.toString() ?? '0') ?? 0.0,
      online: double.tryParse(json['online']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class ExpenseSummary {
  final double total;
  final double cash;
  final double upi;
  final double card;

  ExpenseSummary({
    required this.total,
    required this.cash,
    required this.upi,
    required this.card,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseSummary(
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      cash: double.tryParse(json['cash']?.toString() ?? '0') ?? 0.0,
      upi: double.tryParse(json['upi']?.toString() ?? '0') ?? 0.0,
      card: double.tryParse(json['card']?.toString() ?? '0') ?? 0.0,
    );
  }
}
