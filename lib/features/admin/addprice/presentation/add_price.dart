import 'package:flutter/material.dart';

class AddPriceScreen extends StatefulWidget {
  const AddPriceScreen({super.key});

  @override
  State<AddPriceScreen> createState() => _AddPriceScreenState();
}

class _AddPriceScreenState extends State<AddPriceScreen> {
  final List<Map<String, dynamic>> products = [
    {
      "name": "White Medium",
      "ncc": TextEditingController(text: "5.20"),
      "market": TextEditingController(text: "5.50"),
      "egg": TextEditingController(text: "5.35"),
    },
    {
      "name": "White Bullet",
      "ncc": TextEditingController(text: "6.00"),
      "market": TextEditingController(text: "6.30"),
      "egg": TextEditingController(text: "6.15"),
    },
    {
      "name": "White Small Eggs",
      "ncc": TextEditingController(text: "4.80"),
      "market": TextEditingController(text: "5.00"),
      "egg": TextEditingController(text: "4.90"),
    },
    {
      "name": "Brown Eggs",
      "ncc": TextEditingController(text: "7.20"),
      "market": TextEditingController(text: "7.50"),
      "egg": TextEditingController(text: "7.35"),
    },
    {
      "name": "Country Eggs",
      "ncc": TextEditingController(text: "9.00"),
      "market": TextEditingController(text: "9.50"),
      "egg": TextEditingController(text: "9.25"),
    },
    {
      "name": "Quail Eggs",
      "ncc": TextEditingController(text: "3.20"),
      "market": TextEditingController(text: "3.50"),
      "egg": TextEditingController(text: "3.35"),
    },
    {
      "name": "Duck Eggs",
      "ncc": TextEditingController(text: "8.00"),
      "market": TextEditingController(text: "8.40"),
      "egg": TextEditingController(text: "8.20"),
    },
  ];

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

          style: TextStyle(
            color: Colors.black,
            fontSize: isSmall ? 22 : 26,
            fontWeight: FontWeight.bold,
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

      body: SingleChildScrollView(
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

                                    style: TextStyle(
                                      fontSize: isSmall ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "7 Active Products",

                                    style: TextStyle(
                                      color: Colors.grey,
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
                                Container(
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
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: isSmall ? 18 : 20,
                                      ),

                                      const SizedBox(width: 8),

                                      Text(
                                        "Discard",

                                        style: TextStyle(
                                          fontSize: isSmall ? 13 : 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                /// UPDATE BUTTON
                                Container(
                                  width: isSmall ? 150 : 190,
                                  height: 52,

                                  decoration: BoxDecoration(
                                    color: const Color(0xff071A52),

                                    borderRadius: BorderRadius.circular(16),
                                  ),

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: isSmall ? 18 : 20,
                                      ),

                                      const SizedBox(width: 8),

                                      Text(
                                        "Update Rates",

                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmall ? 13 : 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
                        const Expanded(
                          flex: 3,
                          child: Text(
                            "PRODUCT CATEGORY",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        /// NCC RATE
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              "NCC RATE",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmall ? 9 : 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// MARKET RATE
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              "MARKET RATE",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmall ? 9 : 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// RATE PER EGG
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              "RATE PER EGG (₹)",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmall ? 8 : 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// PRODUCT LIST
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

                                style: TextStyle(
                                  fontSize: isSmall ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            /// NCC RATE
                            Expanded(
                              flex: 2,

                              child: priceField(
                                controller: item["ncc"],
                                isSmall: isSmall,
                              ),
                            ),

                            const SizedBox(width: 8),

                            /// MARKET RATE
                            Expanded(
                              flex: 2,

                              child: priceField(
                                controller: item["market"],
                                isSmall: isSmall,
                              ),
                            ),

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

                      style: TextStyle(
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

            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.bold,
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
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
