class BranchLedgerModel {
  final int id;
  final String branchName;

  BranchLedgerModel({
    required this.id,
    required this.branchName,
  });

  factory BranchLedgerModel.fromJson(Map<String, dynamic> json) {
    return BranchLedgerModel(
      id: json['id'] ?? 0,
      branchName: json['branch_name'] ?? '',
    );
  }
}