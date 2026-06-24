import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_addprice_skeleton_loader.dart';
import 'package:proteinova_connect/services/offer_service.dart';

class AddPriceScreen extends StatefulWidget {
  const AddPriceScreen({super.key});

  @override
  State<AddPriceScreen> createState() => _AddPriceScreenState();
}

class _AddPriceScreenState extends State<AddPriceScreen> {
  final List<Map<String, dynamic>> products = [];
  bool isLoading = false;
  bool isUpdating = false;
  final ScrollController _scrollController = ScrollController();

  bool isRefreshing = false;
  Future<void> refreshDashboard() async {
    setState(() {
      isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    await _fetchCurrentPrices();

    setState(() {
      isRefreshing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentPrices();
  }

  @override
  void dispose() {
    for (final item in products) {
      (item["egg"] as TextEditingController).dispose();
    }
    super.dispose();
  }

  final List<String> productList = [
    "White large",
    "White correct size",
    "white export",
    "white medium",
    "white pullet",
    "white small eggs",
    "Brown eggs",
    "country eggs",
    "quail eggs",
    "duck eggs",
  ];

  Future<void> _fetchCurrentPrices() async {
    setState(() {
      isLoading = true;
    });
    try {
      final dbPrices = await OfferService.getCurrentPrices();
      final fetchedProducts = <Map<String, dynamic>>[];

      for (final name in productList) {
        final found = dbPrices.firstWhere(
          (p) =>
              (p["product_name"] ?? "").toString().toLowerCase() ==
              name.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );

        final price = found["price_per_egg"];
        final parsed = price == null ? null : double.tryParse(price.toString());
        final formatted = parsed != null ? parsed.toStringAsFixed(2) : "0.00";

        fetchedProducts.add({
          "name": name,
          "egg": TextEditingController(text: formatted),
        });
      }

      if (!mounted) return;

      for (final item in products) {
        (item["egg"] as TextEditingController).dispose();
      }
      products
        ..clear()
        ..addAll(fetchedProducts);
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch prices: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _bulkUpdatePrices() async {
     print("Update Rates button clicked");
    setState(() {
      isUpdating = true;
    });
    try {
      final payload = products.map((item) {
        return {
          "product_name": item["name"],
          "price_per_egg": (item["egg"] as TextEditingController).text.trim(),
        };
      }).toList();

      final ok = await OfferService.bulkUpdatePrices(payload);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? "Prices updated successfully" : "Failed to update prices",
          ),
        ),
      );

      if (ok) {
        await _fetchCurrentPrices();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        scrolledUnderElevation: 0,

        title: Text(
          "Pricing Matrix",
          style: AppTextStyles.headingText16.copyWith(
            fontSize: isSmall ? 22 : 22,
            color: Colors.black,
          ),
        ),
      ),

      body: isLoading || isRefreshing
          ? const AdminAddpriceSkeletonLoader()
          : RefreshIndicator(
              onRefresh: refreshDashboard,
              color: AppColors.dark,
              child: SingleChildScrollView(
                controller: _scrollController,

                physics: const AlwaysScrollableScrollPhysics(),

                child: Column(
                  children: [
                    /// MAIN CARD
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(24),

                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withValues(alpha: 0.03),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          /// HEADER
                          Padding(
                            padding: const EdgeInsets.all(18),

                            child: Column(
                              children: [
                                /// TOP
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    /// LEFT
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "Add Price",
                                            style: AppTextStyles.headingText16
                                                .copyWith(
                                                  fontSize: isSmall ? 18 : 22,
                                                ),
                                          ),

                                          SizedBox(
                                            height: getHeight(context, 6),
                                          ),

                                          Text(
                                            "${products.length} Active Products",
                                            style: AppTextStyles.bodyText13,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    /// RIGHT BUTTONS
                                    Column(
                                      children: [
                                        /// DISCARD
                                        GestureDetector(
                                          onTap: isLoading || isUpdating
                                              ? null
                                              : _fetchCurrentPrices,
                                          child: Container(
                                            width: isSmall
                                                ? getWidth(context, 120)
                                                : getWidth(context, 160),
                                            height: getHeight(context, 52),

                                            decoration: BoxDecoration(
                                              color: Colors.white,

                                              borderRadius:
                                                  BorderRadius.circular(16),

                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),

                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,

                                              children: [
                                                Icon(
                                                  Icons.history,
                                                  size: isSmall ? 18 : 20,
                                                ),

                                                const SizedBox(width: 8),

                                                Text(
                                                  "Discard",
                                                  style: AppTextStyles
                                                      .buttonText16
                                                      .copyWith(
                                                        fontSize: isSmall
                                                            ? 13
                                                            : 15,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          height: getHeight(context, 12),
                                        ),

                                        /// UPDATE BUTTON
                                        GestureDetector(
                                          onTap: isLoading || isUpdating
                                              ? null
                                              :(){ print("GestureDetector tapped");
                                               _bulkUpdatePrices();},
                                          child: Container(
                                            width: isSmall
                                                ? getWidth(context, 120)
                                                : getWidth(context, 160),
                                            height: getHeight(context, 52),
                                            decoration: BoxDecoration(
                                              color: AppColors.amber600,

                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),

                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,

                                              children: [
                                                if (isUpdating)
                                                  const SizedBox(
                                                    height: 16,
                                                    width: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                else
                                                  Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: isSmall ? 18 : 20,
                                                  ),

                                                const SizedBox(width: 8),

                                                Text(
                                                  isUpdating
                                                      ? "Updating..."
                                                      : "Update Rates",
                                                  style: AppTextStyles
                                                      .buttonText16
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontSize: isSmall
                                                            ? 13
                                                            : 15,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Divider(
                            color: Colors.grey.shade200,
                            height: getHeight(context, 1),
                          ),

                          /// TABLE HEADER
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(context, 14),
                              vertical: getHeight(context, 12),
                            ),

                            color: const Color(0xffFAFAFA),

                            child: Row(
                              children: [
                                /// PRODUCT
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "PRODUCT CATEGORY",
                                    style: AppTextStyles.bodyText12semibold
                                        .copyWith(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                  ),
                                ),

                                /// NCC RATE
                                SizedBox(width: getWidth(context, 1)),

                                /// RATE PER EGG
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      "RATE PER EGG (₹)",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodyText12semibold
                                          .copyWith(
                                            fontSize: isSmall ? 8 : 10,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// PRODUCT LIST
                          if (isLoading)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: getHeight(context, 24),
                              ),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (products.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: getHeight(context, 24),
                              ),
                              child: Center(
                                child: Text(
                                  "No product categories found in DB",
                                  style: AppTextStyles.bodyText14.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              itemCount: products.length,

                              itemBuilder: (context, index) {
                                final item = products[index];

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: getWidth(context, 14),
                                    vertical: getHeight(context, 14),
                                  ),

                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),

                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,

                                    children: [
                                      /// PRODUCT NAME
                                      SizedBox(width: getWidth(context, 10)),
                                      Expanded(
                                        flex: 3,

                                        child: Text(
                                          item["name"],
                                          style: AppTextStyles.bodyText14dark
                                              .copyWith(
                                                fontSize: isSmall ? 14 : 16,
                                              ),
                                        ),
                                      ),

                                      SizedBox(width: getWidth(context, 8)),

                                      /// RATE PER EGG
                                      Expanded(
                                        flex: 2,

                                        child: priceField(
                                          controller: item["egg"],
                                          isSmall: isSmall,
                                          context,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: getHeight(context, 22)),

                    /// INFO BOX
                    Container(
                      width: getWidth(context, 300),

                      height: getHeight(context, 55),

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: const Color(0xffEEF4FF),

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.10),
                        ),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue,
                            size: isSmall ? 24 : 30,
                          ),

                          SizedBox(width: getWidth(context, 14)),

                          Expanded(
                            child: Text(
                              "All rates are in INR (₹) per egg.",
                              style: AppTextStyles.bodyText16.copyWith(
                                fontSize: isSmall ? 14 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: getHeight(context, 30)),
                  ],
                ),
              ),
            ),
    );
  }

  /// PRICE FIELD
  Widget priceField(
    BuildContext context, {
    required TextEditingController controller,
    required bool isSmall,
  }) {
    return Container(
      height: getHeight(context, 45),

      padding: EdgeInsets.symmetric(horizontal: getWidth(context, 10)),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        children: [
          Text(
            "₹",
            style: AppTextStyles.buttonText16.copyWith(
              fontSize: isSmall ? 14 : 16,
            ),
          ),

          SizedBox(width: getWidth(context, 4)),

          Expanded(
            child: TextField(
              controller: controller,

              textAlign: TextAlign.center,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),

              style: TextStyle(
                color: AppTextStyles.buttonText16.color,
                fontSize: isSmall ? 14 : 16,
                fontWeight: AppTextStyles.buttonText16.fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
