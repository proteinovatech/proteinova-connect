class DamageCategoryModel {
  final String eggCategoryGrade;
  final int traysAvailable;
  final int eggsAvailable;

  DamageCategoryModel({
    required this.eggCategoryGrade,
    required this.traysAvailable,
    required this.eggsAvailable,
  });

  factory DamageCategoryModel.fromJson(Map<String, dynamic> json) {
    return DamageCategoryModel(
      eggCategoryGrade: json['egg_category_grade'] ?? '',
      traysAvailable: json['trays_available'] ?? 0,
      eggsAvailable: json['eggs_available'] ?? 0,
    );
  }
}