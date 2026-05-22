class BranchModel {
  final int id;
  final String branchName;
  final String branchCode;
  final String region;
  final String status;
  final String addressLine1;
  final String city;
  final String postalZipCode;
  final String contactNumber;
  final String emailAddress;
  final int? branchManagerId;
  final String managerEmail;
  final int? maxStockCapacity;
  final String? additionalNotes;
  final int currentStock;
  final double totalSales;
  final double totalRevenue;

  BranchModel({
    required this.id,
    required this.branchName,
    required this.branchCode,
    required this.region,
    required this.status,
    required this.addressLine1,
    required this.city,
    required this.postalZipCode,
    required this.contactNumber,
    required this.emailAddress,
    this.branchManagerId,
    required this.managerEmail,
    this.maxStockCapacity,
    this.additionalNotes,
    this.currentStock = 0,
    this.totalSales = 0,
    this.totalRevenue = 0,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      branchName: json['branch_name'] ?? json['name'] ?? '',
      branchCode: json['branch_code'] ?? json['code'] ?? '',
      region: json['region'] ?? '',
      status: json['status'] ?? '',
      addressLine1: json['address_line1'] ?? json['address'] ?? '',
      city: json['city'] ?? '',
      postalZipCode: json['postal_zip_code']?.toString() ?? json['zip']?.toString() ?? '',
      contactNumber: json['contact_number'] ?? json['phone'] ?? '',
      emailAddress: json['email_address'] ?? json['email'] ?? '',
      branchManagerId: json['branch_manager_id'] ?? json['manager_id'],
      managerEmail: json['branch_manager_email'] ?? json['manager_email'] ?? '',
      maxStockCapacity: json['max_stock_capacity'] ?? json['capacity'],
      additionalNotes: json['additional_notes'] ?? json['notes'],
      currentStock: int.tryParse((json['current_stock'] ?? json['egg_count'] ?? json['total_eggs'] ?? json['stock'] ?? json['branch_stock_eggs'] ?? json['total_stock_eggs'] ?? '0').toString()) ?? 0,
      totalSales: double.tryParse((json['total_sales'] ?? json['sales'] ?? json['mtd_sales'] ?? json['sales_mtd'] ?? json['branch_sales_eggs'] ?? json['total_sales_eggs'] ?? json['total_mtd_sales'] ?? json['today_sales'] ?? json['sales_today'] ?? '0').toString()) ?? 0,
      totalRevenue: double.tryParse((json['total_revenue'] ?? json['revenue'] ?? json['branch_revenue'] ?? json['total_revenue_amount'] ?? json['mtd_revenue'] ?? '0').toString()) ?? 0,
    );
  }
}