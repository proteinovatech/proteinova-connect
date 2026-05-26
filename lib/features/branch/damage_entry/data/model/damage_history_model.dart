class DamageHistoryModel {
  final String date;
  final String category;
  final int damagedEggs;
  final int trays;

  DamageHistoryModel({
    required this.date,
    required this.category,
    required this.damagedEggs,
    required this.trays,
  });

  factory DamageHistoryModel.fromJson(Map<String, dynamic> json) {
    return DamageHistoryModel(
      date: json['date'],
      category: json['category'],
      damagedEggs: json['damaged_eggs'],
      trays: json['trays'],
    );
  }
}