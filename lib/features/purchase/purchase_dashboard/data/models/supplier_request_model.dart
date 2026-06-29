class SupplierRequestModel {
  final String supplierCompanyName;
  final String supplierName;
  final String email;
  final String phoneNumber;
  final String supplierLocation;
  final String status;
  final String gstNumber;
   final int? id;

  SupplierRequestModel({
     this.id,
    required this.supplierCompanyName,
    required this.supplierName,
    required this.email,
    required this.phoneNumber,
    required this.supplierLocation,
    required this.status,
    required this.gstNumber
   
  });

  factory SupplierRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SupplierRequestModel(
      supplierCompanyName:
          json["supplier_company_name"] ?? "",

      supplierName:
          json["supplier_name"] ?? "",

      email:
          json["email"] ?? "",

      phoneNumber:
          json["phone_number"] ?? "",

      supplierLocation:
          json["supplier_location"] ?? "",

      status:
          json["status"] ?? "",

      gstNumber: 
           json["gst_number"] ?? ""
    ); 
  }

  Map<String, dynamic> toJson() {
    return {
      "supplier_company_name":
          supplierCompanyName,

      "supplier_name":
          supplierName,

      "email":
          email,

      "phone_number":
          phoneNumber,

      "supplier_location":
          supplierLocation,

      "status":
          status,

      "gst_number":
          gstNumber,
    };
  }
}