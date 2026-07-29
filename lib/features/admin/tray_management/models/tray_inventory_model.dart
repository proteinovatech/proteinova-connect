class TrayInventoryModel {
  final int id;
  final String locationName;
  final String locationType;
  final int plasticTrayCount;
  final int paperTrayCount;
  final int filledPlasticCount;
  final int filledPaperCount;
  final int coverCount;
  final DateTime updatedAt;

  TrayInventoryModel({
    required this.id,
    required this.locationName,
    required this.locationType,
    required this.plasticTrayCount,
    required this.paperTrayCount,
    required this.filledPlasticCount,
    required this.filledPaperCount,
    required this.coverCount,
    required this.updatedAt,
  });

  factory TrayInventoryModel.fromJson(Map<String, dynamic> json) {
    return TrayInventoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      locationName: json['location_name'] ?? '',
      locationType: json['location_type'] ?? '',
      plasticTrayCount: json['plastic_tray_count'] is int 
          ? json['plastic_tray_count'] 
          : int.tryParse(json['plastic_tray_count']?.toString() ?? '0') ?? 0,
      paperTrayCount: json['paper_tray_count'] is int 
          ? json['paper_tray_count'] 
          : int.tryParse(json['paper_tray_count']?.toString() ?? '0') ?? 0,
      filledPlasticCount: json['filled_plastic_count'] is int 
          ? json['filled_plastic_count'] 
          : int.tryParse(json['filled_plastic_count']?.toString() ?? '0') ?? 0,
      filledPaperCount: json['filled_paper_count'] is int 
          ? json['filled_paper_count'] 
          : int.tryParse(json['filled_paper_count']?.toString() ?? '0') ?? 0,
      coverCount: json['cover_count'] is int 
          ? json['cover_count'] 
          : int.tryParse(json['cover_count']?.toString() ?? '0') ?? 0,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_name': locationName,
      'location_type': locationType,
      'plastic_tray_count': plasticTrayCount,
      'paper_tray_count': paperTrayCount,
      'filled_plastic_count': filledPlasticCount,
      'filled_paper_count': filledPaperCount,
      'cover_count': coverCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
