class BranchManagerModel {
  final int id;
  final String email;
  final String role;

  BranchManagerModel({
    required this.id,
    required this.email,
    required this.role,
  });

  factory BranchManagerModel.fromJson(Map<String, dynamic> json) {
    return BranchManagerModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }
}
