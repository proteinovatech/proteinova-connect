import 'package:proteinova_connect/features/branch/ledger/data/model/branch_ledger_model.dart';

class LedgerEntry {
  final String customerName;
  final String customerNumber;
  final String soldLocation;
  final String salesHappen;

  final double totalCharged;
  final double totalPaid;
  final double outstandingBalance;

  final String lastTransactionDate;
  final int transactionCount;

  LedgerEntry({
    required this.customerName,
    required this.customerNumber,
    required this.soldLocation,
    required this.salesHappen,
    required this.totalCharged,
    required this.totalPaid,
    required this.outstandingBalance,
    required this.lastTransactionDate,
    required this.transactionCount,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      customerName: json["customer_name"] ?? "",
      customerNumber: json["customer_number"] ?? "",
      soldLocation: json["sold_location"] ?? "",
      salesHappen: json["sales_happen"] ?? "",
      totalCharged:
          double.tryParse(json["total_charged"].toString()) ?? 0,
      totalPaid:
          double.tryParse(json["total_paid"].toString()) ?? 0,
      outstandingBalance:
          double.tryParse(json["outstanding_balance"].toString()) ?? 0,
      lastTransactionDate:
          json["last_transaction_date"] ?? "",
      transactionCount:
          int.tryParse(json["transaction_count"].toString()) ?? 0,
    );
  }
}

class Summary {
  final double totalOutstanding;
  final double totalCharged;
  final double totalPaid;
  final int pendingCount;
  final int clearedCount;

  Summary({
    required this.totalOutstanding,
    required this.totalCharged,
    required this.totalPaid,
    required this.pendingCount,
    required this.clearedCount,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalOutstanding:
          double.tryParse(json["total_outstanding"].toString()) ?? 0,
      totalCharged:
          double.tryParse(json["total_charged"].toString()) ?? 0,
      totalPaid:
          double.tryParse(json["total_paid"].toString()) ?? 0,
      pendingCount: json["pending_count"] ?? 0,
      clearedCount: json["cleared_count"] ?? 0,
    );
  }
}
class LedgerModel {
    final Summary summary;
  final List<LedgerEntry> customers;
  final List<BranchLedgerModel> branches;

  LedgerModel({
    required this.summary,
    required this.customers,
    required this.branches,
  });

  factory LedgerModel.fromJson(Map<String, dynamic> json) {
    return LedgerModel(
      summary: Summary.fromJson(json["summary"] ?? {}),
      customers: (json["customers"] as List? ?? [])
          .map((e) => LedgerEntry.fromJson(e))
          .toList(),

      branches: (json["branches"] as List? ?? [])
          .map((e) => BranchLedgerModel.fromJson(e))
          .toList(),
    );
  }
}