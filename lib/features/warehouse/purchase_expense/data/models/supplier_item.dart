class SupplierItem {
  final int id;
  final String? supplierCompanyName;
  final String? supplierName;
  final String? supplierLocation;

  SupplierItem({
    required this.id,
    this.supplierCompanyName,
    this.supplierName,
    this.supplierLocation,
  });

  factory SupplierItem.fromJson(Map<String, dynamic> json) {
    return SupplierItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      supplierCompanyName: json['supplier_company_name']?.toString(),
      supplierName: json['supplier_name']?.toString(),
      supplierLocation: json['supplier_location']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_company_name': supplierCompanyName,
      'supplier_name': supplierName,
      'supplier_location': supplierLocation,
    };
  }
}
