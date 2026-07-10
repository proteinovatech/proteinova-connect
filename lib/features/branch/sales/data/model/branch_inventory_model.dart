class BranchInventory {
  final int? branchId;
  final String category;
  final int totalEggs;

  BranchInventory({
    required this.branchId,
    required this.category,
    required this.totalEggs,
  });

  factory BranchInventory.fromJson(Map<String, dynamic> json) {
    return BranchInventory(
      branchId: json["branch_id"],
      category: json["category"] ?? "",
      totalEggs: json["total_eggs"] ?? 0,
    );
  }
}