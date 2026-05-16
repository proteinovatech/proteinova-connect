import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class PaymentMethod extends StatefulWidget {
  final String selectedPaymentMethod;
  final TextEditingController amountController;
  final TextEditingController debtController;

  final Widget Function(String) paymentTab;
  final Widget Function(String) buildLabel;

  final Widget Function({
    required String hint,
    TextEditingController? controller,
    Widget? prefixIcon
  })
  buildTextField;

  final Widget Function(String, String, {bool red, bool bold}) summaryRow;

  

  const  PaymentMethod({
    super.key,
    required this.selectedPaymentMethod,
    required this.paymentTab,
    required this.buildLabel,
    required this.buildTextField,
    required this.summaryRow,
    required this.amountController,
    required this.debtController,
    required Map<dynamic, dynamic> selectedEggsMap,
  });

  @override
  State< PaymentMethod> createState() =>
      _PaymentSummaryWidgetState();
}

class _PaymentSummaryWidgetState extends State< PaymentMethod> {
 
  String selectedUpiApp = "";

  Widget buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
         boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: child,
    );
  }

  Widget _upiOption({
  required String title,
}) {
  final bool isSelected = selectedUpiApp == title;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedUpiApp = title;
      });
    },

    child: Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),

      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.amber600
            : Colors.grey.shade50,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: isSelected
              ? AppColors.amber600
              : Colors.grey.shade300,
        ),
      ),

      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,

            style:  AppTextStyles.bodyText12semibold.copyWith(
  color: isSelected
      ? Colors.white
      : Colors.black,
),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
       
        buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                "Payment Method",
                style: AppTextStyles.headingText22
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: widget.paymentTab("Cash")),

                  const SizedBox(width: 16),

                  Expanded(child: widget.paymentTab("UPI")),

                ],
              ),

              const SizedBox(height: 24),

             
              if (widget.selectedPaymentMethod == "UPI") ...[
                Text(
                  "Select UPI App",
                  style:AppTextStyles.bodyText16 
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _upiOption(
                        title: "Google Pay",
                        
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _upiOption(
                        title: "PhonePe",
                        
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _upiOption(
                        title: "Paytm",
                        
                      ),
                    ), 
                    const SizedBox(width: 12),

                    Expanded(
                      child: _upiOption(
                        title: "Others",
                        
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                widget.buildLabel("UPI Amount"),

                const SizedBox(height: 8),

                widget.buildTextField(
                  hint: "0.00",
                  controller: widget.amountController,
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
              ] else ...[
                widget.buildLabel(
                  widget.selectedPaymentMethod == "Cash"
                      ? "Enter Amount"
                      : "Card Amount",
                ),

                const SizedBox(height: 8),

                widget.buildTextField(
                  hint: "0.00",
                  controller: widget.amountController,
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
              ],

             if (widget.selectedPaymentMethod != "UPI") ...[
  const SizedBox(height: 24),

  widget.buildLabel("Debit (Optional)"),

  const SizedBox(height: 8),

  widget.buildTextField(
    hint: "0.00",
    controller: widget.debtController,
    prefixIcon: const Icon(Icons.currency_rupee),
  ),
],
            ],
          ),
        ),

        const SizedBox(height: 18),

      ],
    );
  }
}