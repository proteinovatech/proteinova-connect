class SalesEntryModel {

  final Map<String, dynamic> header;

  final List productDetails;

  final List offers;

  final List paymentMethods;

  final Map<String, dynamic>
      billSummaryDefaults;

  SalesEntryModel({

    required this.header,

    required this.productDetails,

    required this.offers,

    required this.paymentMethods,

    required this.billSummaryDefaults,
  });

  factory SalesEntryModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return SalesEntryModel(

      header: json["header"] ?? {},

      productDetails:
          json["product_details"] ?? [],

      offers: json["offers"] ?? [],

      paymentMethods:
          json["payment_methods"] ?? [],

      billSummaryDefaults:
          json["bill_summary_defaults"] ??
              {},
    );
  }
}