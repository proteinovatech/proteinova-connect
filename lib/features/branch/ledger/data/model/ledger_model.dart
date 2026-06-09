class LedgerEntry {
  final int id;
  final String customerName;
  final String customerPhone;
  final double totalBilled;
  final double totalPaid;
  final String? lastPaymentDate;
  final String status; // "Paid", "Partial", "Pending"

  LedgerEntry({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.totalBilled,
    required this.totalPaid,
    this.lastPaymentDate,
    required this.status,
  });

  double get pendingAmount => totalBilled - totalPaid;

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    final billed = double.tryParse(json['total_billed']?.toString() ?? '0') ?? 0.0;
    final paid = double.tryParse(json['total_paid']?.toString() ?? '0') ?? 0.0;

    String status;
    if (paid >= billed) {
      status = 'Paid';
    } else if (paid > 0) {
      status = 'Partial';
    } else {
      status = 'Pending';
    }

    return LedgerEntry(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? 'Unknown',
      customerPhone: json['customer_phone'] ?? '',
      totalBilled: billed,
      totalPaid: paid,
      lastPaymentDate: json['last_payment_date'],
      status: status,
    );
  }
}
