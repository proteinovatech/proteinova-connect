import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
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

  Future<void> _fetchCurrentPrices() async {
    setState(() {
      isLoading = true;
    });
    try {
      final rows = await OfferService.getCurrentPrices();
      final fetchedProducts = <Map<String, dynamic>>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final map = Map<String, dynamic>.from(row);
        final productName = (map["product_name"] ?? "").toString().trim();
        final price = map["price_per_egg"];
        final parsed = price == null ? null : double.tryParse(price.toString());
        if (productName.isEmpty || parsed == null) continue;
        final formatted = parsed.toStringAsFixed(2);
        fetchedProducts.add({
          "name": productName,

          "egg": TextEditingController(text: formatted),
        });
      }
      if (!mounted) return;

      // Fully source product categories from DB response.
      for (final item in products) {
        (item["ncc"] as TextEditingController).dispose();
        (item["market"] as TextEditingController).dispose();
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
      backgroundColor: const Color(0xffF5F5F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F7),
        elevation: 0,

        title: Text(
          "Pricing Matrix",
          style: AppTextStyles.headingText25.copyWith(
            fontSize: isSmall ? 22 : 26,
            color: Colors.black,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),

            child: Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),

                border: Border.all(color: Colors.grey.shade300),
              ),

              child: const Icon(Icons.info_outline, color: Colors.black),
            ),
          ),
        ],
      ),

  body: isLoading
    ? const AdminAddpriceSkeletonLoader()
    : SingleChildScrollView(
        padding: const EdgeInsets.all(16),

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
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Add Price",
                                    style: AppTextStyles.headingText22.copyWith(
                                      fontSize: isSmall ? 18 : 22,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "${products.length} Active Products",
                                    style: AppTextStyles.bodyText14.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: isSmall ? 13 : 15,
                                    ),
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
                                    width: isSmall ? 150 : 190,
                                    height: 52,

                                    decoration: BoxDecoration(
                                      color: Colors.white,

                                      borderRadius: BorderRadius.circular(16),

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
                                          style: AppTextStyles.buttonText16
                                              .copyWith(
                                                fontSize: isSmall ? 13 : 15,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                /// UPDATE BUTTON
                                GestureDetector(
                                  onTap: isLoading || isUpdating
                                      ? null
                                      : _bulkUpdatePrices,
                                  child: Container(
                                    width: isSmall ? 150 : 190,
                                    height: 52,

                                    decoration: BoxDecoration(
                                      color: const Color(0xff071A52),

                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,

                                      children: [
                                        if (isUpdating)
                                          const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
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
                                          style: AppTextStyles.buttonText16
                                              .copyWith(
                                                color: Colors.white,
                                                fontSize: isSmall ? 13 : 15,
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

                  Divider(color: Colors.grey.shade200, height: 1),

                  /// TABLE HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),

                    color: const Color(0xffFAFAFA),

                    child: Row(
                      children: [
                        /// PRODUCT
                        Expanded(
                          flex: 3,
                          child: Text(
                            "PRODUCT CATEGORY",
                            style: AppTextStyles.bodyText12semibold.copyWith(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        /// NCC RATE
                        const SizedBox(width: 8),

                        /// RATE PER EGG
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              "RATE PER EGG (₹)",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyText12semibold.copyWith(
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
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (products.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 22,
                          ),

                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              /// PRODUCT NAME
                              Expanded(
                                flex: 3,

                                child: Text(
                                  item["name"],
                                  style: AppTextStyles.bodyText14dark.copyWith(
                                    fontSize: isSmall ? 14 : 16,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              const SizedBox(width: 8),

                              /// RATE PER EGG
                              Expanded(
                                flex: 2,

                                child: priceField(
                                  controller: item["egg"],
                                  isSmall: isSmall,
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

            const SizedBox(height: 24),

            /// INFO BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color(0xffEEF4FF),

                borderRadius: BorderRadius.circular(18),

                border: Border.all(color: Colors.blue.withValues(alpha: 0.10)),
              ),

              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: isSmall ? 24 : 30),

                  const SizedBox(width: 14),

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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// PRICE FIELD
  Widget priceField({
    required TextEditingController controller,
    required bool isSmall,
  }) {
    return Container(
      height: 52,

      padding: const EdgeInsets.symmetric(horizontal: 10),

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

          const SizedBox(width: 4),

          Expanded(
            child: TextField(
              controller: controller,

              textAlign: TextAlign.right,

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
