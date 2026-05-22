class PurchaseListItem {
  final int id;
  final String? createdAt;
  final String? supplierCompanyName;
  final String? supplierLocation;
  final String? purchasedLocation;
  final String? driverName;
  final int? supplierId;
  final String? purchaseStatus;
  final List<dynamic>? expenses;

  PurchaseListItem({
    required this.id,
    this.createdAt,
    this.supplierCompanyName,
    this.supplierLocation,
    this.purchasedLocation,
    this.driverName,
    this.supplierId,
    this.purchaseStatus,
    this.expenses,
  });

  factory PurchaseListItem.fromJson(Map<String, dynamic> json) {
    return PurchaseListItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      createdAt: json['created_at']?.toString(),
      supplierCompanyName: json['supplier_company_name']?.toString(),
      supplierLocation: json['supplier_location']?.toString(),
      purchasedLocation: json['purchased_location']?.toString(),
      driverName: json['driver_name']?.toString(),
      supplierId: json['supplier_id'] != null
          ? (json['supplier_id'] is int
              ? json['supplier_id'] as int
              : int.tryParse(json['supplier_id'].toString()))
          : null,
      purchaseStatus: json['purchase_status']?.toString(),
      expenses: json['expenses'] is List ? json['expenses'] as List : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'supplier_company_name': supplierCompanyName,
      'supplier_location': supplierLocation,
      'purchased_location': purchasedLocation,
      'driver_name': driverName,
      'supplier_id': supplierId,
      'purchase_status': purchaseStatus,
      'expenses': expenses,
    };
  }
}
