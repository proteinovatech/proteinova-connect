class BranchModel {
  final int id;
  final String branchName;
  final String branchCode;
  final String region;
  final String status;
  final String city;
  final String managerEmail;

  BranchModel({
    required this.id,
    required this.branchName,
    required this.branchCode,
    required this.region,
    required this.status,
    required this.city,
    required this.managerEmail,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      branchName: json['branch_name'] ?? '',
      branchCode: json['branch_code'] ?? '',
      region: json['region'] ?? '',
      status: json['status'] ?? '',
      city: json['city'] ?? '',
      managerEmail: json['branch_manager_email'] ?? '',
    );
  }
}