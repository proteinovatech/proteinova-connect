class Location {
  final int id;
  final String name;
  final String type; // 'branch' or 'warehouse'

  Location({
    required this.id,
    required this.name,
    required this.type,
  });

  factory Location.fromJson(Map<String, dynamic> json, String type) {
    return Location(
      id: json['id'] ?? 0,
      name: (type == 'branch' ? json['branch_name'] : json['warehouse_name']) ?? json['id'].toString(),
      type: type,
    );
  }
}
