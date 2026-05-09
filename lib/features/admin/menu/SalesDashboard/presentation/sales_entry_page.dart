import 'package:flutter/material.dart';

class SalesEntryPage extends StatefulWidget {
  const SalesEntryPage({super.key});

  @override
  State<SalesEntryPage> createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  String selectedCategory = "All Categories";
  List<String> selectedProducts = [
    "Select Product",
    "Select Product",
    "Select Product",
  ];
  TextEditingController dateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),

        titleSpacing: 0,

        title: const Text(
          "Sales Entry",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Text(
              "Log new sales transactions to automatically update branch inventory.",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
            ),

            const SizedBox(height: 20),

            /// VIEW TODAY SALES
            Align(
              alignment: Alignment.center,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 104,
                  vertical: 14,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xffEEF4FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade100),
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt, color: Colors.blue),

                    SizedBox(width: 10),

                    Text(
                      "View Today's Sales",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TRANSACTION DETAILS
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transaction Details",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  buildLabel("Customer Number"),

                  const SizedBox(height: 8),

                  buildTextField(hint: ""),

                  const SizedBox(height: 18),

                  buildLabel("Customer Name"),

                  const SizedBox(height: 8),

                  buildTextField(hint: "Enter customer name"),

                  const SizedBox(height: 18),

                  buildLabel("Sales Date"),

                  const SizedBox(height: 8),

                  buildDateField(),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// PRODUCT SELECTION
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Product Selection",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  buildTextField(
                    hint: "Search product by name",
                    icon: Icons.search,
                  ),

                  const SizedBox(height: 18),

                  buildDropdown(),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// SALES ITEMS
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Sales Items",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        height: 40,
                        width: 40,

                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// TABLE HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),

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
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(width: 6),

                        Expanded(
                          flex: 4,
                          child: Text(
                            "PRODUCT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(width: 6),

                        SizedBox(
                          width: 42,
                          child: Center(
                            child: Text(
                              "DOZEN",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        SizedBox(
                          width: 20,
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
                          width: 32,
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
                          width: 34,
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

                  salesItemRow(1),
                  salesItemRow(2),
                  salesItemRow(3),

                  const SizedBox(height: 20),

                  const Text(
                    "Available Offers",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      "No active offers available.",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// PAYMENT METHOD
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Method",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      paymentTab("Cash", selected: true),

                      const SizedBox(width: 20),

                      paymentTab("UPI"),

                      const SizedBox(width: 20),

                      paymentTab("Card"),
                    ],
                  ),

                  const SizedBox(height: 24),

                  buildLabel("Cash Received"),

                  const SizedBox(height: 8),

                  buildTextField(hint: "0"),

                  const SizedBox(height: 24),

                  buildLabel("Debt (Optional)"),

                  const SizedBox(height: 8),

                  buildTextField(hint: "0"),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// BILL SUMMARY
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bill Summary",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 24),

                  summaryRow("Items (0 - Trays)", "₹ 0"),

                  const SizedBox(height: 16),

                  summaryRow("Offers Discount", "- ₹ 0", red: true),

                  const Divider(height: 30),

                  summaryRow("Total Total", "₹ 0", bold: true),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff12B321),
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      "Complete Transaction",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: 12),

                    Icon(Icons.currency_rupee, color: Colors.white, size: 14),

                    SizedBox(width: 2),

                    Text(
                      "0",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildDateField() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: dateController,
              readOnly: true,

              decoration: const InputDecoration(
                hintText: "Enter Date",
                border: InputBorder.none,
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,

                initialDate: DateTime.now(),

                firstDate: DateTime(2020),

                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                String formattedDate =
                    "${pickedDate.day.toString().padLeft(2, '0')}-"
                    "${pickedDate.month.toString().padLeft(2, '0')}-"
                    "${pickedDate.year}";

                setState(() {
                  dateController.text = formattedDate;
                });
              }
            },

            child: const Icon(Icons.calendar_today, size: 20),
          ),
        ],
      ),
    );
  }

  /// COMMON CARD
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
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  /// LABEL
  Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
  }

  /// TEXT FIELD
  Widget buildTextField({required String hint, IconData? icon}) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),

          if (icon != null) Icon(icon, size: 20),
        ],
      ),
    );
  }

  Widget buildDropdown() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,

          isExpanded: true,

          icon: const Icon(Icons.keyboard_arrow_down),

          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),

          items: ["All Categories", "White eggs"].map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),

          onChanged: (value) {
            setState(() {
              selectedCategory = value!;
            });
          },
        ),
      ),
    );
  }

  /// SALES ITEM ROW
  Widget salesItemRow(int no) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Row(
        children: [
          /// NUMBER
          SizedBox(
            width: 18,

            child: Text(
              "$no",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),

          const SizedBox(width: 6),

          /// PRODUCT DROPDOWN
          Expanded(
            flex: 4,

            child: Container(
              height: 38,

              padding: const EdgeInsets.symmetric(horizontal: 8),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),

                border: Border.all(color: Colors.grey.shade300),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedProducts[no - 1],

                  isExpanded: true,

                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),

                  style: const TextStyle(color: Colors.black, fontSize: 10),

                  items:
                      [
                        "Select Product",
                        "White Medium",
                        "White Bullet",
                        "White Small Eggs",
                        "Brown Eggs",
                        "Country Eggs",
                        "Quail Eggs",
                        "Duck Eggs",
                      ].map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,

                          child: Text(item, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedProducts[no - 1] = value!;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          /// DOZEN
          Container(
            width: 42,
            height: 38,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),

              border: Border.all(color: Colors.grey.shade300),
            ),

            child: const Center(
              child: Text("1", style: TextStyle(fontSize: 12)),
            ),
          ),

          const SizedBox(width: 8),

          /// EGGS
          const SizedBox(
            width: 20,

            child: Center(child: Text("—", style: TextStyle(fontSize: 12))),
          ),

          const SizedBox(width: 10),

          /// RATE
          const SizedBox(
            width: 32,

            child: Text(
              "₹0",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(width: 10),

          /// TOTAL
          const SizedBox(
            width: 34,

            child: Text(
              "₹0",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// DELETE
          const Icon(Icons.delete_outline, size: 18),
        ],
      ),
    );
  }

  /// PAYMENT TAB
  Widget paymentTab(String title, {bool selected = false}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.black,

            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          height: 3,
          width: 40,

          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,

            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  /// SUMMARY ROW
  Widget summaryRow(
    String title,
    String value, {
    bool red = false,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: red ? Colors.red : Colors.black,

            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
