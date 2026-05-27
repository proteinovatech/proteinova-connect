class DamageCategory {
  final String eggCategoryGrade;
  final int traysAvailable;
  final int eggsAvailable;

  DamageCategory({
    required this.eggCategoryGrade,
    required this.traysAvailable,
    required this.eggsAvailable,
  });

  factory DamageCategory.fromJson(Map<String, dynamic> json) {
    return DamageCategory(
      eggCategoryGrade: json['egg_category_grade'] ?? '',
      traysAvailable: json['trays_available'] ?? 0,
      eggsAvailable: json['eggs_available'] ?? 0,
    );
  }
}
