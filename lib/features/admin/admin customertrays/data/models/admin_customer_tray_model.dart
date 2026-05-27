class AdminCustomerTray {
  final String uniqueCustomerId;
  final String customerName;
  final String customerNumber;
  final String soldLocation;
  final String date;
  final String trayType;
  final int traysGiven;
  final int traysReturned;
  final int balance;

  AdminCustomerTray({
    required this.uniqueCustomerId,
    required this.customerName,
    required this.customerNumber,
    required this.soldLocation,
    required this.date,
    required this.trayType,
    required this.traysGiven,
    required this.traysReturned,
    required this.balance,
  });

  factory AdminCustomerTray.fromJson(Map<String, dynamic> json) {
    return AdminCustomerTray(
      uniqueCustomerId: json['unique_customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerNumber: json['customer_number'] ?? '',
      soldLocation: json['sold_location'] ?? '',
      date: json['date'] ?? '',
      trayType: json['tray_type'] ?? '',
      traysGiven: json['trays_given'] ?? 0,
      traysReturned: json['trays_returned'] ?? 0,
      balance: json['balance'] ?? 0,
    );
  }
}
