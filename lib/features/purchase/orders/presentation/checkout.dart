import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/cache/hive_service/purchase_hive_service.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/purchase/orders/widget/checkout_summary.dart';
import 'package:proteinova_connect/features/purchase/orders/widget/payment_method.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/purchase_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/purchase_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/supplier_repository.dart';

class Checkout extends StatefulWidget {
  final PurchaseRequest purchase;

  const Checkout({super.key,required this.purchase});

  @override
  State<Checkout> createState() => _CheckoutState();
}
double subtotal = 5000;
double tax = subtotal * 0.05;
double deliveryFee = 50;

double totalAmount = subtotal + tax + deliveryFee;
int selectedIndex = 0;
final List<String> tabs = [
    "Card",
    "UPI",
    "Wallets",
    "Cash",
    
  ];
  List<IconData> tabIcons = [
  Icons.credit_card,
  Icons.phone_android_outlined,
  Icons.wallet,
  Icons.money,
];
bool isChecked = false;
class _CheckoutState extends State<Checkout> {

  final TextEditingController quantityController = TextEditingController();
final TextEditingController countController = TextEditingController();
final TextEditingController neccController = TextEditingController();
final TextEditingController minusController = TextEditingController();
final TextEditingController trayController = TextEditingController();
final TextEditingController rateController = TextEditingController();
final TextEditingController notesController = TextEditingController();

final TextEditingController branchController=TextEditingController();
final TextEditingController numberController=TextEditingController();
final TextEditingController typeController=TextEditingController();
final TextEditingController contactController=TextEditingController();

final TextEditingController loadingController=TextEditingController();
final TextEditingController unloadingController=TextEditingController();
final TextEditingController transportController=TextEditingController();
final TextEditingController miscController=TextEditingController();

String selectedPaymentMethod = "Cash";

final TextEditingController amountController =
    TextEditingController();

final TextEditingController debtController =
    TextEditingController();

Map selectedEggsMap = {};

double itemTotal = 500;
double offerDiscount = 50;
double grandTotal = 450;

int totalTrayCount = 10;

void calculateSummary() {
  final quantity = double.tryParse(quantityController.text) ?? 0;
  final rate = double.tryParse(rateController.text) ?? 0;

  final loading = 500;   
  final unloading = 300;
  final transport = 1000;
  final misc = 200;

  final totalCost = (quantity * rate) + loading + unloading + transport + misc;

  setState(() {
    
  });
}

@override
void initState() {
  super.initState();

  quantityController.addListener(calculateSummary);
  rateController.addListener(calculateSummary);
  neccController.addListener(calculateSummary);
  minusController.addListener(calculateSummary);

  quantityController.addListener(_refresh);
  rateController.addListener(_refresh);
  countController.addListener(_refresh);
  neccController.addListener(_refresh);
  minusController.addListener(_refresh);

   loadingController.addListener(_refresh);
  unloadingController.addListener(_refresh);
  transportController.addListener(_refresh);
  miscController.addListener(_refresh);
}


void _refresh() {
  setState(() {}); 
}

  @override
  Widget build(BuildContext context) {
     final purchase = widget.purchase;
     final bool isPaymentValid =
    selectedPaymentMethod.isNotEmpty &&
    amountController.text.trim().isNotEmpty &&
    amountController.text.trim() != "0";
   
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    SizedBox(height: size.height * 0.06),

    Row(
      children: [
        SizedBox(width: size.width * 0.04),

        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),

        SizedBox(width: size.width * 0.25),

        Text(
          "Check out",
          style: AppTextStyles.headingText25,
        ),
      ],
    ),

    SizedBox(height: size.height * 0.02),

    const Divider(height: 1),

   
    Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.01),

            Row(
              children: [
                Text(
                  "Sales & Dispatch  >",
                  style: AppTextStyles.bodyText14,
                ),

                SizedBox(width: size.width * 0.01),

                Text(
                  "Order #ORD-8921",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "> Payment",
                  style: AppTextStyles.bodyText14dark,
                ),
              ],
            ),

            SizedBox(height: size.height * 0.01),

            Text(
              "Checkout Payment",
              style: AppTextStyles.headingText22,
            ),

            SizedBox(height: size.height * 0.01),

            Text(
              "Select a payment method to complete Order #ORD-892 ",
              style: AppTextStyles.bodyText14,
            ),

            SizedBox(height: size.height * 0.03),

            PaymentMethod(
              selectedPaymentMethod: selectedPaymentMethod,
              amountController: amountController,
              debtController: debtController,
              selectedEggsMap: selectedEggsMap,

              paymentTab: (method) {
                final bool isSelected =
                    selectedPaymentMethod == method;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = method;
                    });
                  },

                  child: Container(
                    height: 50,
                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.amber600
                          : Colors.grey.shade100,

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: isSelected
                            ? AppColors.amber600
                            : Colors.grey.shade300,
                      ),
                    ),

                    child: Text(
                      method,
                      style:
                          AppTextStyles.bodyText13.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },

              buildLabel: (text) {
                return Text(
                  text,
                  style: AppTextStyles.buttonText16
                );
              },

              buildTextField: ({
                required String hint,
                TextEditingController? controller,
                Widget?prefixIcon
              }) {
                return TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,

                  decoration: InputDecoration(
                    hintText: hint,
                    prefixIcon: prefixIcon,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                );
              },

              summaryRow: (
                String title,
                String value, {
                bool red = false,
                bool bold = false,
              }) {
                return Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: bold
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),

                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: red
                            ? Colors.red
                            : Colors.black,
                        fontWeight: bold
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: getHeight(context, 10)),

           BlocProvider(
  create: (_) => PurchaseBloc(
    SupplierRepository(DioClient().dio),
    PurchaseRepository(
      DioClient().dio,
      PurchaseCacheService(),
    ),
    PurchaseCacheService(),
  ),

  child: CheckoutSummary(
    purchase: purchase,
    isPaymentValid: true,
  ),
),

            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  ],
),
    );
  }
}