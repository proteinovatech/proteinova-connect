class DamageLocation {
  final String id;
  final String name;
  final String type; // 'WAREHOUSE' or 'BRANCH'

  DamageLocation({
    required this.id,
    required this.name,
    required this.type,
  });

  factory DamageLocation.fromJson(Map<String, dynamic> json) {
    return DamageLocation(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}
