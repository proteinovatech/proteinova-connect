class ManagerModel {
  final int id;
  final String email;
  final String role;

  ManagerModel({
    required this.id,
    required this.email,
    required this.role,
  });

  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      id: json["id"],
      email: json["email"],
      role: json["role"],
    );
  }
}

class BranchFormDataModel {
  final List<String> statuses;
  final List<String> regions;
  final List<ManagerModel> managers;

  BranchFormDataModel({
    required this.statuses,
    required this.regions,
    required this.managers,
  });

  factory BranchFormDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BranchFormDataModel(
      statuses: List<String>.from(json["statuses"]),
      regions: List<String>.from(json["regions"]),

      managers: (json["managers"] as List)
          .map((e) => ManagerModel.fromJson(e))
          .toList(),
    );
  }
}