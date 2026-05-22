class BranchSelectorModel {
  final int id;
  final String branchName;

  BranchSelectorModel({
    required this.id,
    required this.branchName,
  });

  factory BranchSelectorModel.fromJson(Map<String, dynamic> json) {
    return BranchSelectorModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      branchName: json['branch_name']?.toString() ?? json['name']?.toString() ?? '',
    );
  }
}
