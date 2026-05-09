import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/Distribution/widget/dispatch_planning_widget.dart';


class DispatchPlanningPage extends StatelessWidget {
  const DispatchPlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xffF6F7FB),
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),

        titleSpacing: 0,

        title: const Text(
          "Dispatch Planning",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TITLE
              const Text(
                "New Dispatch",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                "Manage dispatching to update inventory",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),

              const SizedBox(height: 22),

              /// SHOP & DISPATCH INFO
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    sectionTitle("1", "Shop & Dispatch Info"),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: buildField(
                            label: "Select Shop *",
                            hint: "Select Branch",
                            dropdown: true,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: buildField(
                            label: "Dispatch Date *",
                            hint: "08-05-2026",
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: buildField(
                            label: "Expected Arrival Date *",
                            hint: "dd-mm-yyyy",
                            icon: Icons.calendar_today,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: buildField(
                            label: "Vehicle No. *",
                            hint: "TN 32 B 2134",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: buildField(
                            label: "Driver Name *",
                            hint: "John Doe",
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: buildField(
                            label: "Driver Number *",
                            hint: "9876543210",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// ITEMS TO DISPATCH
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// TOP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Expanded(child: sectionTitle("2", "Items to Dispatch")),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),

                            border: Border.all(color: const Color(0xffE8C400)),
                          ),

                          child: const Row(
                            children: [
                              Icon(Icons.add, size: 16),

                              SizedBox(width: 4),

                              Text(
                                "Add Item",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// HEADER
                    const Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Product",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            "Available\n(Trays)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            "Eggs\n(Entry)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            "Trays\n(Auto)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Divider(color: Colors.grey.shade300, thickness: 1),

                    const SizedBox(height: 4),

                    /// ROW
                    Row(
                      children: [
                        /// PRODUCT
                        Expanded(
                          flex: 4,

                          child: Container(
                            height: 42,

                            padding: const EdgeInsets.symmetric(horizontal: 10),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(color: Colors.grey.shade300),
                            ),

                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Expanded(
                                  child: Text(
                                    "Select Category",
                                    overflow: TextOverflow.ellipsis,

                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),

                                Icon(Icons.keyboard_arrow_down, size: 18),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// AVAILABLE
                        const Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              "-",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// EGGS
                        Expanded(flex: 2, child: numberBox("0")),

                        const SizedBox(width: 8),

                        /// TRAYS
                        Expanded(flex: 2, child: numberBox("0")),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Divider(color: Colors.grey.shade300, thickness: 1),

                    const SizedBox(height: 18),

                    /// TOTAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: const [
                        Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "0 Eggs",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "0 Trays",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// EMPTY TRAY DISPATCH
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    sectionTitle("3", "Empty Tray Dispatch"),

                    const SizedBox(height: 6),

                    Text(
                      "Specify additional empty trays being dispatched along with the product",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          Expanded(
                            child: trayCard(
                              iconColor: Colors.blue,
                              title: "Plastic Trays",
                              subtitle: "(Empty)",
                              desc:
                                  "Durable plastic trays used for return purposes",
                              extra: "",
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: trayCard(
                              iconColor: Colors.orange,
                              title: "Paper Trays",
                              subtitle: "(Empty)",
                              desc: "Paper pulp trays used for transport",
                              extra: "Non - Returnable",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// DISPATCH SUMMARY
              buildCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        sectionTitle("4", "Dispatch Summary"),

                        Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),

                            border: Border.all(color: Colors.blue.shade100),
                          ),

                          child: Icon(
                            Icons.description,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    summaryRow("Total Products", "0 Types"),

                    summaryRow("Total Eggs", "0"),

                    summaryRow("Product Trays", "0"),

                    summaryRow("Plastic Trays (Empty Returnable)", "0"),

                    summaryRow("Paper Trays (Empty Non-Returnable)", "0"),

                    summaryRow("Grand Total Trays (Prod + Empty)", "0"),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// OVERALL DISPATCH
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    sectionTitle("5", "Overall Dispatch"),

                    const SizedBox(height: 18),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          /// LEFT CARD
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,

                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),

                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(
                                        alpha: 0.08,
                                      ),

                                      borderRadius: BorderRadius.circular(12),
                                    ),

                                    child: Icon(
                                      Icons.shield_outlined,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,

                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: const [
                                        Text(
                                          "Plastic trays are returnable",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        SizedBox(height: 8),

                                        Text(
                                          "Paper trays are non - returnable",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// RIGHT CARD
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.08),

                                borderRadius: BorderRadius.circular(16),

                                border: Border.all(color: Colors.green),
                              ),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),

                                      SizedBox(width: 8),

                                      Expanded(
                                        child: Text(
                                          "Overall Dispatch",
                                          overflow: TextOverflow.ellipsis,

                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  const Text(
                                    "0 Trays 0 Eggs",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// NOTES
              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      height: 110,

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: Colors.grey.shade300),
                      ),

                      child: Text(
                        "Enter any additional notes...",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// BUTTONS
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 58,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),

                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Container(
                      height: 58,

                      decoration: BoxDecoration(
                        color: const Color(0xffFFD600),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Center(
                        child: Text(
                          "Dispatch Now",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// CARD
  static Widget buildCard({required Widget child}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

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

  /// SECTION TITLE
  static Widget sectionTitle(String number, String title) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 26,

          decoration: const BoxDecoration(
            color: Color(0xffFFD600),
            shape: BoxShape.circle,
          ),

          child: Center(
            child: Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// FIELD
  static Widget buildField({
    required String label,
    required String hint,
    bool dropdown = false,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),

        const SizedBox(height: 8),

        Container(
          height: 54,

          padding: const EdgeInsets.symmetric(horizontal: 14),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),

            border: Border.all(color: Colors.grey.shade300),
          ),

          child: Row(
            children: [
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),

              if (dropdown) const Icon(Icons.keyboard_arrow_down),

              if (icon != null) Icon(icon, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  
}
