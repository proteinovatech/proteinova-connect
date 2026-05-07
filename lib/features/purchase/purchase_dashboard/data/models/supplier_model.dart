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
      id: json['id'],
      companyName: json['supplier_company_name'],
      supplierName: json['supplier_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      location: json['supplier_location'],
      status: json['status'],
    );
  }
}