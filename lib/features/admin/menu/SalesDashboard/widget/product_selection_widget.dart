import 'package:flutter/material.dart';

class ProductSelectionWidget extends StatelessWidget {
  final TextEditingController searchController;

  final List filteredProducts;

  final Widget buildDropdown;

  final Function(String) onSearch;

  final Future<void> Function(String productName) onProductTap;

  final num Function(dynamic value) toNum;
final Map<String, int> selectedEggsMap;
  const ProductSelectionWidget({
    super.key,
    required this.searchController,
    required this.filteredProducts,
    required this.buildDropdown,
    required this.onSearch,
    required this.onProductTap,
    required this.toNum,
    required this.selectedEggsMap,
  });

  Widget buildCard({required Widget child}) {
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

      child: child,
    );
  }

  Widget buildTextField({
    required String hint,
    IconData? icon,
    TextEditingController? controller,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,

      onChanged: onChanged,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: icon != null ? Icon(icon) : null,

        filled: true,

        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Product Selection",

            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// SEARCH
          buildTextField(
            hint: "Search product by name",

            icon: Icons.search,

            controller: searchController,

            onChanged: onSearch,
          ),

          const SizedBox(height: 18),

          /// DROPDOWN
          buildDropdown,

          const SizedBox(height: 20),

          /// RESPONSIVE PRODUCT GRID
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;

              /// MOBILE
              if (constraints.maxWidth < 600) {
                crossAxisCount = 2;
              }
              /// TABLET
              else if (constraints.maxWidth < 1000) {
                crossAxisCount = 3;
              }
              /// DESKTOP
              else {
                crossAxisCount = 5;
              }

              // ── Empty state ──────────────────────────────────
              if (filteredProducts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 32,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No Stock Available",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "This branch currently has no products in stock.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // ── Product Grid ─────────────────────────────────
              return GridView.builder(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: filteredProducts.length,

                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,

                  crossAxisSpacing: 12,

                  mainAxisSpacing: 12,

                  childAspectRatio: constraints.maxWidth < 600 ? 0.78 : 0.72,
                ),

                itemBuilder: (context, index) {
                  final product = filteredProducts[index];

                  final String productName =
                      product['product_name']?.toString() ?? "";

                  final double trayPrice = toNum(
                    product['per_tray_price'] ?? product['price'] ?? 0,
                  ).toDouble();

                  /// STOCK
                  final int actualStock =
                      int.tryParse((product['stock_eggs'] ?? 0).toString()) ??
                      0;

                  final int usedStock = selectedEggsMap[productName] ?? 0;

                  final int stockEggs = actualStock - usedStock;

                  /// 1 EGG RATE
                  final double eggRate = trayPrice > 0 ? trayPrice / 30 : 0;

                  return Material(
                    color: Colors.transparent,

                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),

                      /// Not clickable when stock is 0
                      onTap: stockEggs <= 0
                          ? null
                          : () async {
                              await onProductTap(productName);
                            },

                      child: Opacity(
                        opacity: stockEggs <= 0 ? 0.5 : 1,

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),

                          curve: Curves.easeInOut,

                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(16),

                            border: Border.all(
                              color: stockEggs <= 0
                                  ? Colors.red.shade100
                                  : Colors.grey.shade200,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),

                                blurRadius: 10,

                                spreadRadius: 1,

                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              /// PRODUCT NAME
                              SizedBox(
                                height: 40,

                                child: Text(
                                  productName,

                                  maxLines: 2,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,

                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// RATE
                              Text(
                                "₹ ${eggRate.toStringAsFixed(2)}",

                                style: const TextStyle(
                                  fontSize: 24,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              const Text(
                                "/ Per Egg",

                                style: TextStyle(
                                  color: Colors.grey,

                                  fontSize: 12,
                                ),
                              ),

                              const Spacer(),

                              /// STOCK BADGE
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: stockEggs > 0
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: stockEggs > 0
                                        ? Colors.green.shade200
                                        : Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      stockEggs > 0
                                          ? Icons.check_circle_outline
                                          : Icons.cancel_outlined,
                                      size: 11,
                                      color: stockEggs > 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        stockEggs > 0
                                            ? "$stockEggs eggs"
                                            : "No Stock",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: stockEggs > 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
