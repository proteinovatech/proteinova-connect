class AssetModel {
  final int id;
  final String name;
  final String assetId;
  final String category;
  final int quantity;
  final String location;
  final String status;
  final String createdAt;
  final String updatedAt;

  AssetModel({
    this.id = 0,
    required this.name,
    required this.assetId,
    this.category = 'General',
    this.quantity = 0,
    this.location = 'Unknown',
    this.status = 'Available',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      assetId: json['asset_id'] ?? '',
      category: json['category'] ?? 'General',
      quantity: json['quantity'] ?? 0,
      location: json['location'] ?? 'Unknown',
      status: json['status'] ?? 'Available',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'asset_id': assetId,
      'category': category,
      'quantity': quantity,
      'location': location,
      'status': status,
    };
  }
}
