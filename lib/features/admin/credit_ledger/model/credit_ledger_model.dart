class CreditLedgerModel {
  final double totalOutstanding;
  final double totalCharged;
  final double totalReceived;
  final int pendingCustomers;
  final int clearedCustomers;
  final List<dynamic> customers;

  CreditLedgerModel({
    required this.totalOutstanding,
    required this.totalCharged,
    required this.totalReceived,
    required this.pendingCustomers,
    required this.clearedCustomers,
    required this.customers,
  });

  factory CreditLedgerModel.fromJson(Map<String, dynamic> json) {
    return CreditLedgerModel(
      totalOutstanding: (json['totalOutstanding'] ?? 0).toDouble(),
      totalCharged: (json['totalCharged'] ?? 0).toDouble(),
      totalReceived: (json['totalReceived'] ?? 0).toDouble(),
      pendingCustomers: json['pendingCustomers'] ?? 0,
      clearedCustomers: json['clearedCustomers'] ?? 0,
      customers: json['customers'] ?? [],
    );
  }
}
