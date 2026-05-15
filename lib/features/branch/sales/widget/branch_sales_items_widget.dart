import 'package:flutter/material.dart';

class BranchSalesItemsWidget extends StatefulWidget {
  final int salesItemCount;

  final VoidCallback onAdd;

  final List<Map<String, dynamic>> salesItems;

  final Widget Function(int) salesItemRow;
  final Function(List<int>) onOffersApplied;
  final List offers;

  const BranchSalesItemsWidget({
    super.key,
    required this.salesItemCount,
    required this.onAdd,
    required this.salesItemRow,
    required this.offers,
    required this.salesItems,
    required this.onOffersApplied,
  });

  @override
  State<BranchSalesItemsWidget> createState() => _BranchSalesItemsWidgetState();
}

class _BranchSalesItemsWidgetState extends State<BranchSalesItemsWidget> {
  final Map<int, bool> appliedOffers = {};
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Sales Items",

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              GestureDetector(
                onTap: widget.onAdd,

                child: Container(
                  height: 40,
                  width: 40,

                  decoration: BoxDecoration(
                    color: Colors.blue,

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// TABLE HEADER
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,

              borderRadius: BorderRadius.circular(12),
            ),

            child: const Row(
              children: [
                SizedBox(
                  width: 18,

                  child: Text(
                    "#",

                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(width: 6),

                Expanded(
                  flex: 4,

                  child: Text(
                    "PRODUCT",

                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(width: 6),

                SizedBox(
                  width: 42,

                  child: Center(
                    child: Text(
                      "TRAYS",

                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8),

                SizedBox(
                  width: 28,

                  child: Center(
                    child: Text(
                      "EGGS",

                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10),

                SizedBox(
                  width: 36,

                  child: Center(
                    child: Text(
                      "RATE",

                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10),

                SizedBox(
                  width: 40,

                  child: Center(
                    child: Text(
                      "TOTAL",

                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8),

                Icon(Icons.delete_outline, size: 16),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// SALES ROWS
          ...List.generate(
            widget.salesItemCount,
            (index) => widget.salesItemRow(index + 1),
          ),

          const SizedBox(height: 25),

          /// OFFER TITLE
          const Text(
            "Available Offers",

            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// NO OFFERS
          widget.offers.isEmpty
              ? Center(
                  child: Text(
                    "No active offers available.",

                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              /// OFFERS LIST
              : Column(
                  children: List.generate(widget.offers.length, (index) {
                    final offer = widget.offers[index];

                    final String offerCategory =
                        offer["category"]?.toString().toLowerCase() ?? "";

                    bool productMatched = false;

                    int totalEggs = 0;
                    int totalTrays = 0;

                    /// LOOP SALES ITEMS
                    for (int i = 0; i < widget.salesItemCount; i++) {
                      if (i >= widget.salesItems.length) {
                        continue;
                      }

                      final row = widget.salesItems[i];

                      final String productName = row["product_name"]
                          .toString()
                          .toLowerCase();

                      /// USE EGGS DIRECTLY
                      final int eggs =
                          int.tryParse(row["eggs"].toString()) ?? 0;

                      /// PRODUCT MATCH
                      if (productName.contains(offerCategory)) {
                        productMatched = true;

                        totalEggs += eggs;
                        totalTrays += (eggs ~/ 30);
                      }
                    }

                    /// OFFER APPLY
                    final bool eligible = offer["offer_type"] == "buy_x_get_y"
                        ? totalTrays >=
                              (int.tryParse(
                                    (offer["buy_qty"] ?? offer["buyTrays"] ?? 0)
                                        .toString(),
                                  ) ??
                                  0)
                        : productMatched;

                    bool isApplied = appliedOffers[index] == true;

                    // if (offer["offer_type"] == "buy_x_get_y") {
                    //   /// API VALUE = EGGS COUNT
                    //   // final int needEggs =
                    //   //     int.tryParse(offer["buyTrays"].toString()) ?? 0;
                    //   final int needEggs =
                    //       int.tryParse(
                    //         (offer["buyTrays"] ??
                    //                 offer["buy_quantity"] ??
                    //                 offer["minimum_quantity"] ??
                    //                 0)
                    //             .toString(),
                    //       ) ??
                    //       0;
                    //   isApplied = totalDozens >= needEggs;
                    // } else {
                    //   /// FIXED OFFER
                    //   isApplied = productMatched;
                    // }

                    return Container(
                      width: double.infinity,

                      margin: const EdgeInsets.only(bottom: 14),

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: !productMatched
                            ? Colors.grey.shade50
                            : isApplied
                            ? const Color(0xffEAFBF3)
                            : Colors.white,

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(
                          color: !productMatched
                              ? Colors.grey.shade300
                              : isApplied
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),

                      child: Row(
                        children: [
                          /// LEFT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                /// TITLE
                                Text(
                                  offer["offer_type"] == "buy_x_get_y"
                                      ? "${offer["name"]} — Buy ${offer["buy_qty"] ?? offer["buyTrays"]} Get ${offer["getTrays"] ?? offer["get_quantity"] ?? 1 ?? 1}"
                                      : "${offer["name"]} — ₹${offer["discount_value"] ?? offer["amount"] ?? 50} OFF",

                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                /// CATEGORY
                                Text(
                                  offer["category"].toString().toUpperCase(),

                                  style: TextStyle(
                                    color: Colors.grey.shade600,

                                    fontSize: 13,

                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Entered Trays : $totalTrays",
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          /// STATUS BUTTON
                          /// STATUS BUTTON
                          GestureDetector(
                            onTap: () {
                              if (!eligible) return;

                              setState(() {
                                appliedOffers[index] = true;
                              });

                              widget.onOffersApplied(
                                appliedOffers.entries
                                    .where((e) => e.value)
                                    .map((e) => e.key)
                                    .toList(),
                              );
                            },

                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),

                              decoration: BoxDecoration(
                                color: !eligible
                                    ? Colors.grey.shade100
                                    : isApplied
                                    ? Colors.green
                                    : Colors.blue.shade50,

                                borderRadius: BorderRadius.circular(12),

                                border: Border.all(
                                  color: !eligible
                                      ? Colors.grey.shade400
                                      : isApplied
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                              ),

                              child: Text(
                                !eligible
                                    ? "Need More"
                                    : isApplied
                                    ? "✓ Applied"
                                    : "Apply Offer",

                                style: TextStyle(
                                  color: !eligible
                                      ? Colors.grey
                                      : isApplied
                                      ? Colors.white
                                      : Colors.blue,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
        ],
      ),
    );
  }
}