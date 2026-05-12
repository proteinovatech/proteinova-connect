import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/widget/print_%20bill_widget.dart';

class PaymentSummaryWidget extends StatelessWidget {
  final String selectedPaymentMethod;

  final Widget Function(String) paymentTab;

  final Widget Function(String) buildLabel;

  final Widget Function({required String hint}) buildTextField;

  final Widget Function(String, String, {bool red, bool bold}) summaryRow;

  final String itemTrayCount;
  final String itemTotal;
  final String offerDiscount;
  final String grandTotal;

  final Future<void> Function() onSubmit;
  const PaymentSummaryWidget({
    super.key,
    required this.selectedPaymentMethod,
    required this.paymentTab,
    required this.buildLabel,
    required this.buildTextField,
    required this.summaryRow,
    required this.itemTrayCount,
    required this.itemTotal,
    required this.offerDiscount,
    required this.grandTotal,
    required this.onSubmit,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  Expanded(child: paymentTab("Cash")),

                  const SizedBox(width: 16),

                  Expanded(child: paymentTab("UPI")),

                  const SizedBox(width: 16),

                  Expanded(child: paymentTab("Card")),
                ],
              ),

              const SizedBox(height: 24),

              buildLabel(
                selectedPaymentMethod == "Cash"
                    ? "Cash Received"
                    : selectedPaymentMethod == "UPI"
                    ? "UPI Amount"
                    : "Card Amount",
              ),

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

              summaryRow("Items ($itemTrayCount - Trays)", "₹ $itemTotal"),

              const SizedBox(height: 16),

              summaryRow("Offers Discount", "- ₹ $offerDiscount", red: true),

              const Divider(height: 30),

              summaryRow("Total Total", "₹ $grandTotal", bold: true),
            ],
          ),
        ),

        const SizedBox(height: 15),

        /// SUBMIT BUTTON
        SizedBox(
          width: double.infinity,
          height: 52,

          child: ElevatedButton(
            onPressed: () async {
              /// SAVE TO DB
              await onSubmit();

              /// SUCCESS + PRINT
              showDialog(
                context: context,

                barrierDismissible: false,

                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Container(
                      width: 350,

                      padding: const EdgeInsets.all(20),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          /// ICON
                          Container(
                            height: 80,
                            width: 80,

                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 60,
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// TITLE
                          const Text(
                            "Order Saved Successfully!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Grand Total : ₹ $grandTotal",

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// BUTTONS
                          Row(
                            children: [
                              /// CLOSE
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },

                                  child: const Text("Close"),
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// PRINT
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                  ),

                                  onPressed: () {
                                    showDialog(
                                      context: context,

                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child: Padding(
                                            padding: const EdgeInsets.all(20),

                                            child: PrintBillWidget(
                                              grandTotal: grandTotal,

                                              selectedPaymentMethod:
                                                  selectedPaymentMethod,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },

                                  icon: const Icon(
                                    Icons.print,
                                    color: Colors.black,
                                  ),

                                  label: const Text(
                                    "Print",

                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff12B321),

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Text(
                  "Complete Transaction",

                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 12),

                const Icon(Icons.currency_rupee, color: Colors.white, size: 14),

                const SizedBox(width: 2),

                Text(
                  grandTotal,

                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
