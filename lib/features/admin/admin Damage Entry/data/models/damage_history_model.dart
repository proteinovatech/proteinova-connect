class DamageHistory {
  final int id;
  final String locationType;
  final String locationName;
  final String eggCategoryGrade;
  final int damagedEggs;
  final int damagedTrays;
  final String createdAt;

  DamageHistory({
    required this.id,
    required this.locationType,
    required this.locationName,
    required this.eggCategoryGrade,
    required this.damagedEggs,
    required this.damagedTrays,
    required this.createdAt,
  });

  factory DamageHistory.fromJson(Map<String, dynamic> json) {
    return DamageHistory(
      id: json['id'] ?? 0,
      locationType: json['location_type'] ?? '',
      locationName: json['location_name'] ?? '',
      eggCategoryGrade: json['egg_category_grade'] ?? '',
      damagedEggs: json['damaged_eggs'] ?? 0,
      damagedTrays: json['damaged_trays'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
