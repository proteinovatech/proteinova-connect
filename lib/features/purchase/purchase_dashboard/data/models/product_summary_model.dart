class ProductSummary {
  final String category;
  final String quantity;
  final String rate;
  final String totalEggs;
  String? marketPriceMinus;
  String? neccRate;
  String? trayType;

  ProductSummary({
    required this.category,
    required this.quantity,
    required this.rate,
    required this.totalEggs,
     this.marketPriceMinus,
    this.neccRate,
    this.trayType,
  });
}