class SupplierRequestModel {

  final String supplierCompanyName;
  final String supplierName;
  final String email;
  final String phoneNumber;
  final String supplierLocation;
  final String status;

  SupplierRequestModel({
    required this.supplierCompanyName,
    required this.supplierName,
    required this.email,
    required this.phoneNumber,
    required this.supplierLocation,
    required this.status,
  });

  Map<String, dynamic> toJson() {

    return {
      "supplier_company_name": supplierCompanyName,
      "supplier_name": supplierName,
      "email": email,
      "phone_number": phoneNumber,
      "supplier_location": supplierLocation,
      "status": status,
    };
  }
}