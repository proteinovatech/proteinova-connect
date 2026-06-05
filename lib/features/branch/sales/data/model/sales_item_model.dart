class SalesItem {
  String eggCategoryGrade;
  double dozen;
  int trays;
  int eggs;
  double price;
  double total;

  SalesItem({
    this.eggCategoryGrade = "",
    this.dozen = 0,
    this.trays = 0,
    this.eggs = 0,
    this.price = 0,
    this.total = 0,
  });

  // void calculateEggs() {
  //   // 1 Tray = 30 eggs, 1 Dozen = 12 eggs
  //   eggs = (trays * 30) + (dozen * 12).round();
  //   total = double.parse((eggs * price).toStringAsFixed(2));
  // }

  void calculateEggs() {
    calculateFromDozen();
  }

  void calculateFromDozen() {
    // Convert dozen → eggs
    eggs = (dozen * 12).round();

    // Auto tray round up
    trays = (eggs / 30).ceil();

    // Total amount
    total = double.parse((eggs * price).toStringAsFixed(2));
  }

  void calculateFromTrays() {
    // Convert trays → eggs
    eggs = trays * 30;

    // Convert eggs → dozen
    dozen = double.parse((eggs / 12).toStringAsFixed(2));

    // Total amount
    total = double.parse((eggs * price).toStringAsFixed(2));
  }

  SalesItem copyWith({
    String? eggCategoryGrade,
    double? dozen,
    int? trays,
    int? eggs,
    double? price,
    double? total,
  }) {
    return SalesItem(
      eggCategoryGrade: eggCategoryGrade ?? this.eggCategoryGrade,
      dozen: dozen ?? this.dozen,
      trays: trays ?? this.trays,
      eggs: eggs ?? this.eggs,
      price: price ?? this.price,
      total: total ?? this.total,
    );
  }
}
