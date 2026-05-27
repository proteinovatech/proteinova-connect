class SupplierModel {
  final int id;
  final String companyName;
  final String supplierName;
  final String email;
  final String phoneNumber;
  final String location;
  final String status;

  SupplierModel({
    required this.id,
    required this.companyName,
    required this.supplierName,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.status,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      companyName: json['supplier_company_name'] as String? ?? '',
      supplierName: json['supplier_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      location: json['supplier_location'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}