import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/widget/add_offer_widget.dart';

class AddOfferBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
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
  String selectedProduct = "Select Egg Category";
  String selectedOfferType = "Fixed Amount";
  String selectedDiscountUnit = "Per Egg";

  bool isActive = true;

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
                    child: const Icon(Icons.close, color: Color(0xff6B7280), size: 20),
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
                  /// OFFER NAME
                  buildLabel("Offer Name"),

                  const SizedBox(height: 12),

                  buildTextField(hint: "e.g. Summer Offer"),

                  const SizedBox(height: 20),

                  /// PRODUCT + OFFER TYPE
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel("Product Name"),
                            const SizedBox(height: 12),
                            buildDropdown(
                              value: selectedProduct,
                              items: const [
                                "Select Egg Category",
                                "Chicken Egg",
                                "Duck Egg",
                                "Organic Egg",
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedProduct = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel("Offer Type"),
                            const SizedBox(height: 12),
                            buildDropdown(
                              value: selectedOfferType,
                              items: const ["Fixed Amount", "Percentage"],
                              onChanged: (value) {
                                setState(() {
                                  selectedOfferType = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// DISCOUNT VALUE + UNIT
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel("Discount Value"),
                            const SizedBox(height: 12),
                            buildTextField(hint: "e.g. 0.20"),
                          ],
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel("Discount Unit"),
                            const SizedBox(height: 12),
                            buildDropdown(
                              value: selectedDiscountUnit,
                              items: const ["Per Egg", "Per Tray"],
                              onChanged: (value) {
                                setState(() {
                                  selectedDiscountUnit = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// DATES
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel("Start Date"),
                            const SizedBox(height: 12),
                            buildDateField(),
                          ],
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel("End Date"),
                            const SizedBox(height: 12),
                            buildDateField(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// ACTIVE CHECKBOX
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: isActive,
                          activeColor: const Color(0xff2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              isActive = value!;
                            });
                          },
                        ),
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
                  Container(
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xffEEF2FF),
                          ),
                          child: const Icon(
                            Icons.local_offer_outlined,
                            size: 28,
                            color: Color(0xff374151),
                          ),
                        ),

                        const SizedBox(width: 16),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Offer Preview",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff111827),
                                ),
                              ),

                              SizedBox(height: 6),

                              Text(
                                "Preview will be shown here once you fill in the details.",
                                style: TextStyle(
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
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          /// BOTTOM BUTTONS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
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

                const SizedBox(width: 12),

                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xff2563EB), Color(0xff3B82F6)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
