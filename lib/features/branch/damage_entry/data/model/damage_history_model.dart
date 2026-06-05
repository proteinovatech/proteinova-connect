class DamageHistoryModel {
   final int id;
  final String date;
  final String category;
  final int damagedEggs;
  final int trays;

  DamageHistoryModel({
     required this.id,
    required this.date,
    required this.category,
    required this.damagedEggs,
    required this.trays,
  });

  factory DamageHistoryModel.fromJson(Map<String, dynamic> json) {
    return DamageHistoryModel(
      id: json['id'] ?? 0,

      category: json['egg_category_grade'] ?? '',

      damagedEggs: json['damaged_eggs'] ?? 0,

      trays: json['damaged_trays'] ?? 0,

      date: _formatDate(json['created_at']),
    );
  }
   static String _formatDate(String? date) {

    if (date == null || date.isEmpty) return '';

    final parsedDate = DateTime.parse(date);

    return "${parsedDate.day.toString().padLeft(2, '0')}-"
           "${parsedDate.month.toString().padLeft(2, '0')}-"
           "${parsedDate.year}";
  }
  }
