import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase/orders/presentation/checkout.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/product_summary_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/purchase_model.dart';

class PurchaseSummaryCard extends StatelessWidget {
  final String supplier;
  final String location;
  final String warehouselocation;
  final String loading;
  final String unloading;
  final String transport;
  final String misc;
  final List<ProductSummary> products;

  
  const PurchaseSummaryCard({
    super.key,
    required this.products,
    required this.supplier,
    required this.location,
    required this.warehouselocation,
    required this.loading,
    required this.unloading,
    required this.transport,
    required this.misc,
    });

  @override
  Widget build(BuildContext context) {
    
    final Size size=MediaQuery.of(context).size;
    
    
double productTotal = 0;
for (var p in products) {
  
  final qty = double.tryParse(p.quantity) ?? 0;
  final rate = double.tryParse(p.rate) ?? 0;
  productTotal += qty * 30 * rate; 
}

final load = double.tryParse(loading) ?? 0;
final unload = double.tryParse(unloading) ?? 0;
final trans = double.tryParse(transport) ?? 0;
final miscCost = double.tryParse(misc) ?? 0;

final additionalTotal = load + unload + trans + miscCost;
final totalCost = productTotal + additionalTotal;
double totalTrays = 0;
    for (var p in products) {
  final qty = double.tryParse(p.quantity) ?? 0;
  totalTrays += qty;
}
final costPerTray =
    totalTrays == 0 ? 0 : productTotal / totalTrays;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔹 Title
          
              Text(
                "Purchase Summary",
                style: AppTextStyles.headingText25,
              ),
           

          
           SizedBox(height: size.height*0.01),

          // 🔹 Empty rows (placeholders)
          _buildRow("Supplier",supplier),
          _buildRow("Location",location),
          Divider(),
         Text(
  "Products",
  style: AppTextStyles.formInputs15dark,
),

const SizedBox(height: 8),

...products.map((p) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow("Category", p.category),
        _buildRow("Quantity", p.quantity),
        _buildRow("Rate", "₹ ${p.rate}"),
        _buildRow("Total Eggs", p.totalEggs),
      ],
    ),
  );
}).toList(),
            SizedBox(height: size.height*0.01),
          Divider(),
            SizedBox(height: size.height*0.01),
          Text("Additional Costs",style: AppTextStyles.formInputs15dark,),
          _buildRow("Loading Charges", "₹ $loading"),
          _buildRow("Unloading Charges", "₹ $unloading"),
          _buildRow("Transport", "₹ $transport"),
          _buildRow("Misc Expense", "₹ $misc"),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Text(
                "Total Additional Cost",
                style: AppTextStyles.formInputs15dark,
              ),
              Text(
                "₹ $additionalTotal", // placeholder
                style: AppTextStyles.bodyText14dark,
              ),
            ],
          ),
            SizedBox(height: size.height*0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cost per Tray",
                style: AppTextStyles.formInputs15dark,
              ),
              Text(
                "₹ ${costPerTray.toStringAsFixed(2)}",// placeholder
                style: AppTextStyles.bodyText14dark,
              ),
            ],
          ),

          SizedBox(height: size.height*0.02),


          // 🔹 Dotted Divider
          Row(
            children: List.generate(
              30,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 1,
                  color: index % 2 == 0
                      ? Colors.grey
                      : Colors.transparent,
                ),
              ),
            ),
          ),

          SizedBox(height: size.height*0.01),

          // 🔹 Total Row (empty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Estimated Cost",
                style: AppTextStyles.headingText22,
              ),
              Text(
                "₹ $totalCost", // placeholder
                style: AppTextStyles.blueText,
              ),
            ],
          ),
          
        Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.amber600
            ),
          
          child: ElevatedButton(
            onPressed: () {

  final purchase = PurchaseRequest(
    supplierName: supplier,
    supplierId: 1, 
    warehouseLocation: warehouselocation,
    expectedArrival: "2026-04-26", // pass properly

    driverName: "Suresh", // make dynamic
    driverNumber: "9123456780",
    vehicleNumber: "TN09XY5678",
    vehicleType: "Mini Truck",

    loadingCharge: double.tryParse(loading) ?? 0,
    unloadingCharge: double.tryParse(unloading) ?? 0,
    transportCharge: double.tryParse(transport) ?? 0,
    miscExpense: double.tryParse(misc) ?? 0,

    purchaseStatus: "PURCHASED",

    items: products.map((p) {
  return PurchaseItem(
    grade: p.category,
    trays: int.tryParse(p.quantity) ?? 0,
    capacity: 30,
    price: double.tryParse(p.rate) ?? 0,

    marketPriceMinus: double.tryParse(p.marketPriceMinus ?? "0") ?? 0,
    neccRate: double.tryParse(p.neccRate ?? "0") ?? 0,
    trayType: p.trayType ?? "", // 🚨 MUST NOT BE NULL
  );
}).toList(),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Checkout(purchase: purchase),
    ),
  );
},
            style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
            ),
            child:  Row(
              children: [
                 SizedBox(width: size.width*0.08),
        
                Icon(Icons.check_circle_outline, color: AppColors.dark),
                 SizedBox(width: size.width*0.02),
                Text(
                        "Submit Purchase Entry",
                        style: AppTextStyles.headingText20
                ),
              ],
            ),
          ),
        ),
        
        
        Row(
          children: [
            Icon(Icons.info_outline,color: AppColors.textSecondary,),
            SizedBox(width: size.width*0.01,),
            Text("Stock will be marked as \'incoming\'  upon\nsubmission",style: AppTextStyles.formInputs15),
          ],
        )
         
         

        ],
      ),
    );
  }

  // 🔧 Row without value (placeholder)
  Widget _buildRow(String title,String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.formInputs15),
           Text(
            value.isEmpty ? "--" : value, // placeholder
            style: AppTextStyles.bodyText16,
          ),
        ],
      ),
    );
  }
}