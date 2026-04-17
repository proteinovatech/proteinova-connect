                                                                                                                                  import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/orders/presentation/purchase_success_screen.dart';
import 'package:proteinova_connect/features/orders/widget/checkout_summary.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

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
void calculateSummary() {
  final quantity = double.tryParse(quantityController.text) ?? 0;
  final rate = double.tryParse(rateController.text) ?? 0;

  final loading = 500;   // later connect from controller
  final unloading = 300;
  final transport = 1000;
  final misc = 200;

  final totalCost = (quantity * rate) + loading + unloading + transport + misc;

  setState(() {
    // You can store this in a variable if needed
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
    
    String supplier = "";
String location = "";
String category = "";
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.06),
          Row(
            children: [
            SizedBox(width: size.width*0.04,),

            GestureDetector(
              onTap: () {
             Navigator.pop(context); 
              },
              child: Icon(Icons.arrow_back)),
             SizedBox(width: size.width*0.25,),
            Text("Check out",style: AppTextStyles.headingText25,),
          ],),
          SizedBox(height: size.height * 0.02),
          const Divider(height: 1,),
          SizedBox(height: size.height * 0.01),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Sales & Dispatch  >",
                      style: AppTextStyles.bodyText14,
                    ),
                    SizedBox(width: size.width*0.01,),
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
                SizedBox(height: size.height*0.01),
                Text(
                  "Checkout Payment",
                  style: AppTextStyles.headingText22,
                ),
                 SizedBox(height: size.height*0.01),
                Text(
                  "Select a payment method to complete Order #ORD-892 ",
                  style: AppTextStyles.bodyText14,
                ),
                
              ],
            ),
          ),

          SizedBox(height: size.height * 0.03),

          /// 🔥 SCROLLABLE AREA
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [ 
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                         Text(
                            "Payment Method",
                            style: AppTextStyles.headingText22,
                          ),
                        SizedBox(height: size.height * 0.03),
   SizedBox(
   height: size.height * 0.05,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Row(
              children: [
                 Icon(
      tabIcons[index],
      color: selectedIndex == index
          ? AppColors.dark
          : Colors.grey,
    ),
SizedBox(width: 5,),
                Text(
                  tabs[index],
                  style: AppTextStyles.bodyText16.copyWith(
                    color: selectedIndex == index
                        ? AppColors.dark
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          
        ),
  );
  },
  ),),
    Stack(
      children: [

        /// Grey full line
        Container(
          height: 3,
          width: double.infinity,
          color: const Color.fromARGB(255, 250, 246, 246),
        ),

        /// Yellow moving indicator
        AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment(
            -1 + (2 / (tabs.length - 1)) * selectedIndex,
            0,
          ),
          child: Container(
            height: 3,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.amber500,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    ),                   
SizedBox(height: 10,),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [

    /// 🔹 LEFT TEXT
    Text(
      "Enter Card Details",
      style: AppTextStyles.headingText20,
    ),

    /// 🔹 RIGHT SIDE (2 containers)
    Row(
      children: [

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
             color: AppColors.containerColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text("VISA"),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
          color: AppColors.containerColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text("MC"),
        ),
      ],
    ),
  ],
),
SizedBox(height: 10,),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// 🔹 LABEL
    Text(
      "Card Number",
      style: AppTextStyles.buttonText16,
    ),

    const SizedBox(height: 8),

    /// 🔹 INPUT CONTAINER
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,

          /// 🔹 CARD ICON
          prefixIcon: Icon(Icons.credit_card),

          hintText: "Enter card number",
          suffixIcon:Icon(Icons.check_circle_outline, color: AppColors.green),
     
        ),
        
      ),
         
    ),
    
  ],
),
SizedBox(height: 10,),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "Name on Card",
      style: AppTextStyles.buttonText16,
    ),

    const SizedBox(height: 8),

    /// 🔹 INPUT CONTAINER
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        keyboardType: TextInputType.name,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Admin User",         
        ),        
      ),
        ),
        SizedBox(height: 10,),
     Column(
  children: [

    /// 🔹 LABEL ROW
    Row(
      children: [
        Expanded(
          child: Text("Expiry Date"),
        ),
        Expanded(
          child: Text("CVV"),
        ),
      ],
    ),

    const SizedBox(height: 8),

    /// 🔹 INPUT ROW
    Row(
      children: [

        /// Expiry Date Field
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "MM/YY",
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        /// CVV Field
     Expanded(
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
  obscureText: true,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    border: InputBorder.none,
    hintText: "123",

    suffixIconConstraints: const BoxConstraints(
      minWidth: 30,
      minHeight: 30,
    ),

    suffixIcon: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
        ),
        padding: const EdgeInsets.all(6),
        child: const Text(
          "?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ),
)
  ),
)
      ],
    ),
    SizedBox(height: 10,),
   Row(
  children: [
    GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: Container(
        height: 22,
        width: 22,
        decoration: BoxDecoration(
          color: isChecked ? Colors.blue : Colors.transparent,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: isChecked
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    ),
    const SizedBox(width: 10),
    const Text("Save this card for future payments"),
  ],
)
  ],
),
    ],
),
             ],
                      ),
                    ),
                  SizedBox(height: 10),
                   CheckoutSummary(
          supplier: supplier, 
          location: location, 
          product: category, 
          quantity: quantityController.text, 
          rate: rateController.text, 
          
          totalEggs: countController.text, 
          loading: loadingController.text, 
          unloading: unloadingController.text, 
          transport: transportController.text, 
          misc: miscController.text
          )
                  ],
                ),
              ),
            ),
          ),
         
       
        ],
      ),
    );
  }
}