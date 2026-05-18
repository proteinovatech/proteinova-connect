import 'package:flutter/material.dart';

class BranchPaymentSummaryWidget extends StatefulWidget {
  final String selectedPaymentMethod;
  final TextEditingController amountController;
  final TextEditingController debtController;

  final Widget Function(String) paymentTab;
  final Widget Function(String) buildLabel;

  final Widget Function({
    required String hint,
    TextEditingController? controller,
  })
  buildTextField;

  final Widget Function(String, String, {bool? red, bool? bold}) summaryRow;

  final String itemTrayCount;
  final String itemTotal;
  final String offerDiscount;
  final String grandTotal;

  final Future<void> Function() onSubmit;
  final Map<dynamic, dynamic> selectedEggsMap;

  const BranchPaymentSummaryWidget({
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
    required this.amountController,
    required this.debtController,
    required this.selectedEggsMap,
  });

  @override
  State<BranchPaymentSummaryWidget> createState() =>
      _PaymentSummaryWidgetState();
}

class _PaymentSummaryWidgetState extends State<BranchPaymentSummaryWidget> {
  bool isSubmitting = false;

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
            // ignore: deprecated_member_use
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
    final double discountValue = double.tryParse(widget.offerDiscount) ?? 0;

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
                  Expanded(child: widget.paymentTab("Cash")),
                  const SizedBox(width: 16),
                  Expanded(child: widget.paymentTab("UPI")),
                  const SizedBox(width: 16),
                  Expanded(child: widget.paymentTab("Card")),
                ],
              ),
              const SizedBox(height: 24),
              widget.buildLabel(
                widget.selectedPaymentMethod == "Cash"
                    ? "Cash Received"
                    : widget.selectedPaymentMethod == "UPI"
                    ? "UPI Amount"
                    : "Card Amount",
              ),
              const SizedBox(height: 8),
              widget.buildTextField(
                hint: "0",
                controller: widget.amountController,
              ),
              const SizedBox(height: 24),
              widget.buildLabel("Debt (Optional)"),
              const SizedBox(height: 8),
              widget.buildTextField(
                hint: "0",
                controller: widget.debtController,
              ),
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
              widget.summaryRow(
                "Items (${widget.itemTrayCount} - Trays)",
                "₹ ${widget.itemTotal}",
              ),
              const SizedBox(height: 16),
              if (discountValue > 0)
                widget.summaryRow(
                  "Offers Discount",
                  "- ₹ ${widget.offerDiscount}",
                  red: true,
                ),
              if (discountValue > 0) const Divider(height: 30),
              widget.summaryRow(
                "Grand Total",
                "₹ ${widget.grandTotal}",
                bold: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        /// SUBMIT BUTTON
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () async {
                    if (widget.amountController.text.trim().isEmpty ||
                        widget.amountController.text.trim() == "0") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Please enter payment amount"),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      isSubmitting = true;
                    });

                    try {
                      await widget.onSubmit();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Failed : $e"),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          isSubmitting = false;
                        });
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff12B321),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
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
                      const Icon(
                        Icons.currency_rupee,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.grandTotal,
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
