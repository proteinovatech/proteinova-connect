import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/admin/widget/add_offer_widget.dart';
import 'package:proteinova_connect/services/offer_service.dart';

class AddOfferBottomSheet {
  static Future<dynamic> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const AddOfferScreen();
      },
    );
  }
}

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController buyQtyController = TextEditingController();
  final TextEditingController freeQtyController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String selectedProduct = "Select Egg Category";
  String selectedOfferType = "Fixed Amount";
  String selectedDiscountUnit = "Per Egg";

  bool isActive = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Listen to controller changes to update preview
    nameController.addListener(() => setState(() {}));
    discountController.addListener(() => setState(() {}));
    buyQtyController.addListener(() => setState(() {}));
    freeQtyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    discountController.dispose();
    buyQtyController.dispose();
    freeQtyController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveOffer() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter offer name")));
      return;
    }

    setState(() {
      isSaving = true;
    });

    final offerData = {
      "offer_name": nameController.text.trim(),
      "product_name": selectedProduct == "Select Egg Category"
          ? null
          : selectedProduct,
      "offer_type": selectedOfferType,
      "discount_value": double.tryParse(discountController.text) ?? 0.0,
      "discount_unit": selectedDiscountUnit,
      "buy_qty": int.tryParse(buyQtyController.text) ?? 0,
      "free_qty": int.tryParse(freeQtyController.text) ?? 0,
      "start_date": startDateController.text,
      "end_date": endDateController.text,
      "is_active": isActive,
    };

    final success = await OfferService.createOffer(offerData);

    setState(() {
      isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create offer")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .93,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          /// TOP HANDLE
          const SizedBox(height: 10),

          Container(
            height: 6,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xffD1D5DB),
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          const SizedBox(height: 18),

          /// TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Add New Offer",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff111827),
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xffF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xff6B7280),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Divider(color: Colors.grey.shade300, height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel(context, "Offer Name", isRequired: true),
                  const SizedBox(height: 10),
                  buildTextField(
                    hint: "e.g. Summer Offer",
                    controller: nameController,
                  ),

                  const SizedBox(height: 20),

                  /// PRODUCT + OFFER TYPE
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel(context, "Product", isRequired: true),
                            const SizedBox(height: 10),
                            buildDropdown(
                              value: selectedProduct,
                              items: const [
                                "Select Egg Category",
                                "All Products",
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
                              ],
                              onChanged: (val) =>
                                  setState(() => selectedProduct = val!),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel(context, "Offer Type", isRequired: true),
                            const SizedBox(height: 10),
                            buildDropdown(
                              value: selectedOfferType,
                              items: [
                                "Fixed Amount",
                                "Percentage",
                                "Buy X Get Y",
                              ],
                              onChanged: (val) =>
                                  setState(() => selectedOfferType = val!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// DISCOUNT VALUE + UNIT
                  if (selectedOfferType != "Buy X Get Y")
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel(
                                context,
                                "Discount Value",
                                isRequired: true,
                              ),
                              const SizedBox(height: 10),
                              buildTextField(
                                hint: "0.00",
                                controller: discountController,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel(context, "Unit", isRequired: true),
                              const SizedBox(height: 10),
                              buildDropdown(
                                value: selectedDiscountUnit,
                                items: ["Per Egg", "Per Tray", "Total Bill"],
                                onChanged: (val) =>
                                    setState(() => selectedDiscountUnit = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  /// BUY X GET Y
                  if (selectedOfferType == "Buy X Get Y")
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel(
                                context,
                                "Buy Quantity",
                                isRequired: true,
                              ),
                              const SizedBox(height: 10),
                              buildTextField(
                                hint: "0",
                                controller: buyQtyController,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel(
                                context,
                                "Free Quantity",
                                isRequired: true,
                              ),
                              const SizedBox(height: 10),
                              buildTextField(
                                hint: "0",
                                controller: freeQtyController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  /// DATES
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel(context, "Start Date", isRequired: true),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () =>
                                  _selectDate(context, startDateController),
                              child: IgnorePointer(
                                child: buildDateField(
                                  controller: startDateController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel(context, "End Date", isRequired: true),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () =>
                                  _selectDate(context, endDateController),
                              child: IgnorePointer(
                                child: buildDateField(
                                  controller: endDateController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// TOGGLE
                  Row(
                    children: [
                      Switch(
                        value: isActive,
                        onChanged: (val) => setState(() => isActive = val),
                        // ignore: deprecated_member_use
                        activeColor: const Color(0xff2563EB),
                      ),
                      const Text(
                        "Is Active",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff111827),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Inactive offers will not be visible to customers.",
                      style: TextStyle(fontSize: 13, color: Color(0xff9CA3AF)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 20),

                  /// PREVIEW BOX
                  _previewBox(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          /// BOTTOM BUTTONS
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Material(
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xffCBD5E1)),
                          ),
                          child: const Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff111827),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: isSaving ? null : _saveOffer,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                           color: AppColors.amber600
                          ),
                          child: Center(
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Save Offer",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffEEF2FF),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 28,
              color: Color(0xff374151),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameController.text.isEmpty
                      ? "Offer Preview"
                      : nameController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getPreviewDescription(),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xff6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPreviewDescription() {
    if (selectedOfferType == "Buy X Get Y") {
      if (buyQtyController.text.isEmpty || freeQtyController.text.isEmpty) {
        return "Preview will be shown here once you fill in the details.";
      }
      return "Buy ${buyQtyController.text} and get ${freeQtyController.text} free on $selectedProduct.";
    } else {
      if (discountController.text.isEmpty) {
        return "Preview will be shown here once you fill in the details.";
      }
      final symbol = selectedOfferType == "Percentage" ? "%" : "₹";
      return "Get $symbol${discountController.text} off $selectedDiscountUnit on $selectedProduct.";
    }
  }
}

class AddPriceMatrixScreen extends StatefulWidget {
  const AddPriceMatrixScreen({super.key});

  @override
  State<AddPriceMatrixScreen> createState() => _AddPriceMatrixScreenState();
}

class _AddPriceMatrixScreenState extends State<AddPriceMatrixScreen> {
  final List<Map<String, dynamic>> products = [];
  bool loading = false;
  bool fetching = true;

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
    "duck eggs"
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentPrices();
  }

  @override
  void dispose() {
    for (final item in products) {
      (item["controller"] as TextEditingController).dispose();
    }
    super.dispose();
  }

  Future<void> _fetchCurrentPrices() async {
    setState(() {
      fetching = true;
    });
    try {
      final dbPrices = await OfferService.getCurrentPrices();
      final List<Map<String, dynamic>> fetchedProducts = [];
      for (final name in productList) {
        final found = dbPrices.firstWhere(
          (p) => (p["product_name"] ?? "").toString().toLowerCase() == name.toLowerCase(),
          orElse: () => null,
        );
        final price = found != null ? found["price_per_egg"] : "";
        fetchedProducts.add({
          "product_name": name,
          "controller": TextEditingController(text: price?.toString() ?? ""),
        });
      }
      setState(() {
        for (final item in products) {
          (item["controller"] as TextEditingController).dispose();
        }
        products.clear();
        products.addAll(fetchedProducts);
        fetching = false;
      });
    } catch (error) {
      print("Error fetching prices: $error");
      setState(() {
        fetching = false;
      });
    }
  }

  Future<void> _handleSaveAll() async {
    setState(() {
      loading = true;
    });
    try {
      final List<Map<String, dynamic>> payload = products.map((item) {
        return {
          "product_name": item["product_name"],
          "price_per_egg": (item["controller"] as TextEditingController).text.trim(),
        };
      }).toList();

      final success = await OfferService.bulkUpdatePrices(payload);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pricing Matrix Updated Successfully.")),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error saving data.")),
          );
        }
      }
    } catch (error) {
      print("Error saving prices: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error saving data.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = products.where((p) => (p["controller"] as TextEditingController).text.isNotEmpty).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Pricing Matrix", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Global Market Rates",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$activeCount Active Products",
                      style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Discard", style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: loading ? null : _handleSaveAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber600,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text("Update All", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Main Body
          Expanded(
            child: fetching
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber600)),
                        SizedBox(height: 16),
                        Text("Fetching master data...", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = products[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item["product_name"],
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Row(
                                  children: [
                                    const Text("₹", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: TextField(
                                        controller: item["controller"],
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "0.00",
                                          isCollapsed: true,
                                        ),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

