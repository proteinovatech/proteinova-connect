class Supplier {
  final String name;
  final String id;
  final String location;
  final String owner;
  final String phone;
  final String email;
  final bool active;

  Supplier({
    required this.name,
    required this.id,
    required this.location,
    required this.owner,
    required this.phone,
    required this.email,
    required this.active,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id']?.toString() ?? '',
      name: json['supplier_company_name'] ?? json['name'] ?? '',
      location: json['supplier_location'] ?? '',
      owner: json['supplier_name'] ?? json['owner'] ?? '',
      phone: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      active: json['status'] == 'Active' || json['status'] == 'ACTIVE' || json['status'] == true || json['active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_company_name': name,
      'supplier_location': location,
      'supplier_name': owner,
      'phone_number': phone,
      'email': email,
      'status': active ? 'ACTIVE' : 'INACTIVE',
    };
  }
}