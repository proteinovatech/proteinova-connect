class BranchModel {
  final int id;
  final String branchName;
  final String branchCode;
  final String city;
  final String contactNumber;
  final String addressLine1;
  final String addressLine2;
  final String status;
  final int maxStockCapacity;
  final int trayCapacityLimit;
  final int deliveryRadius;
  final String operatingHours;
  final bool autoApproveClosing;

  BranchModel({
    required this.id,
    required this.branchName,
    required this.branchCode,
    required this.city,
    required this.contactNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.status,
    required this.maxStockCapacity,
    required this.trayCapacityLimit,
    required this.deliveryRadius,
    required this.operatingHours,
    required this.autoApproveClosing,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: int.tryParse(json["id"]?.toString() ?? '') ?? 0,
      branchName: json["branch_name"] ?? "",
      branchCode: json["branch_code"] ?? "",
      city: json["city"] ?? "",
      contactNumber: json["contact_number"] ?? "",
      addressLine1: json["address_line1"] ?? "",
      addressLine2: json["address_line2"] ?? "",
      status: json["status"] ?? "",
      maxStockCapacity: json["max_stock_capacity"] ?? 0,
      trayCapacityLimit: json["tray_capacity_limit"] ?? 0,
      deliveryRadius: json["delivery_radius"] ?? 0,
      operatingHours: json["operating_hours"] ?? "",
      autoApproveClosing: json["auto_approve_closing"] ?? false,
    );
  }
}
