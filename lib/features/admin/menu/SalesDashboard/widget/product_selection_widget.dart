import 'package:flutter/material.dart';

class ProductSelectionWidget extends StatelessWidget {
  final TextEditingController searchController;

  final List filteredProducts;

  final Widget buildDropdown;

  final Function(String) onSearch;

  final Future<void> Function(String productName) onProductTap;

  final num Function(dynamic value) toNum;

  const ProductSelectionWidget({
    super.key,
    required this.searchController,
    required this.filteredProducts,
    required this.buildDropdown,
    required this.onSearch,
    required this.onProductTap,
    required this.toNum,
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
                  final int stockEggs =
                      int.tryParse(product['stock_eggs'].toString()) ?? 0;

                  /// 1 EGG RATE
                  final double eggRate = trayPrice / 30;

                  return Material(
                    color: Colors.transparent,

                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),

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

                            border: Border.all(color: Colors.grey.shade200),

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

                              /// STOCK
                              Text(
                                "Stock: $stockEggs eggs",

                                maxLines: 2,

                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(
                                  color: stockEggs > 0
                                      ? Colors.green
                                      : Colors.red,

                                  fontWeight: FontWeight.w600,

                                  fontSize: 12,
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
