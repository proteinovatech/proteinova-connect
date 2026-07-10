class SalesEntryModel {
  final Map<String, dynamic> header;
  final List<ProductDetail> productDetails;
  final List<OfferModel> offers;
  final Map<String, dynamic> billSummaryDefaults;

  SalesEntryModel({
    required this.header,
    required this.productDetails,
    required this.offers,
    required this.billSummaryDefaults,
  });

  factory SalesEntryModel.fromJson(Map<String, dynamic> json) {
    return SalesEntryModel(
      header: json["header"] ?? {},
      productDetails: (json["product_details"] as List? ?? [])
          .map((e) => ProductDetail.fromJson(e))
          .toList(),
      offers: (json["offers"] as List? ?? [])
          .map((e) => OfferModel.fromJson(e))
          .toList(),
      billSummaryDefaults: json["bill_summary_defaults"] ?? {},
    );
  }
}

class ProductDetail {
  final String productName;
  final double perTrayPrice;
  final int stockEggs;
  final int stockTrays;

  ProductDetail({
    required this.productName,
    required this.perTrayPrice,
    required this.stockEggs,
    required this.stockTrays,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      productName: json["product_name"] ?? "",
      perTrayPrice: double.tryParse(json["per_tray_price"].toString()) ?? 0.0,
      stockEggs: int.tryParse(json["stock_eggs"].toString()) ?? 0,
      stockTrays: int.tryParse(json["stock_trays"].toString()) ?? 0,
    );
  }
}

class OfferModel {
  final int id;
  final String name;
  final String category;
  final int buyTrays;
  final double buyQty;
  final double freeQty;
  final double discountValue;
  final String offerType;
  bool applied;

  OfferModel({
    required this.id,
    required this.name,
    required this.category,
    required this.buyTrays,
    required this.buyQty,
    required this.freeQty,
    required this.discountValue,
    required this.offerType,
    this.applied = false,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final rawBuy = json["buy_qty"] ?? json["buyTrays"] ?? 0;
    final parsedBuy = double.tryParse(rawBuy.toString()) ?? 0.0;
    return OfferModel(
      id: json["id"] ?? 0,
      name: json["name"] ?? json["offer_name"] ?? "",
      category: json["category"] ?? json["product_name"] ?? "",
      buyTrays: parsedBuy.toInt(),
      buyQty: parsedBuy,
      freeQty: double.tryParse((json["free_qty"] ?? 0).toString()) ?? 0.0,
      discountValue: double.tryParse((json["discount_value"] ?? 0).toString()) ?? 0.0,
      offerType: json["offer_type"] ?? "buy_x_get_y",
    );
  }
}
class InventoryByBranch {
  final int branchId;
  final String category;
  final int totalEggs;

  InventoryByBranch({
    required this.branchId,
    required this.category,
    required this.totalEggs,
  });

  factory InventoryByBranch.fromJson(Map<String, dynamic> json) {
    return InventoryByBranch(
      branchId: json["branch_id"] ?? 0,
      category: json["category"] ?? "",
      totalEggs: json["total_eggs"] ?? 0,
    );
  }
}