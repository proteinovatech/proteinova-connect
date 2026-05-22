class ProductInput {
  String quantity;
  String rate;
  String category;
  String trayType;
  String totalEggs;
   String necc;
  String minus;

  ProductInput({
    this.quantity = '',
    this.rate = '',
    this.category = '',
    this.trayType = '',
    this.totalEggs = '',
     this.necc = '',
    this.minus = '',
  });

  ProductInput copyWith({
    String? category,
    String? quantity,
    String? rate,
    String? totalEggs,
    String? necc,
    String? minus,
    String? trayType,
  }) {
    return ProductInput(
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      totalEggs: totalEggs ?? this.totalEggs,
      necc: necc ?? this.necc,
      minus: minus ?? this.minus,
      trayType: trayType ?? this.trayType,
    );
  }
}