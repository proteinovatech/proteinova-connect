import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/purchase/orders/presentation/purchase_success_screen.dart';
import 'package:proteinova_connect/features/admin/purchase/data/models/purchase_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/purchase/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/admin/purchase/bloc/purchase/purchase_event.dart';
import 'package:proteinova_connect/features/admin/purchase/bloc/purchase/purchase_state.dart';

class CheckoutSummary extends StatefulWidget {
   final PurchaseRequest purchase;
   final bool isPaymentValid;
  const CheckoutSummary({
    super.key,
    required this.purchase,
     required this.isPaymentValid,
    });

  @override
  State<CheckoutSummary> createState() => _CheckoutSummaryState();
}

class _CheckoutSummaryState extends State<CheckoutSummary> {
  
  @override
  Widget build(BuildContext context) {
      final purchase = widget.purchase;

    final Size size=MediaQuery.of(context).size;
    double productTotal = 0;
double totalTrays = 0;

for (var item in widget.purchase.items) {
  productTotal += item.trays * item.capacity * item.perEggPrice;
  totalTrays += item.trays;
}

final additionalTotal =
    widget.purchase.loadingCharge +
    widget.purchase.unloadingCharge +
    widget.purchase.transportCharge +
    widget.purchase.miscExpense+
    widget.purchase.brokerFee;

final totalCost = productTotal + additionalTotal;

final costPerTray =
    totalTrays == 0 ? 0 : totalCost / totalTrays;

    return BlocListener<PurchaseBloc, PurchaseState>(
      listener: (context, state) {

    if (state is PurchaseSubmitSuccess) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PurchaseSuccessScreen(
            purchase: purchase,
          ),
        ),
      );
    }

    if (state is PurchaseSubmitFailure) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
        ),
      );
    }
  },
      child: Container(
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
            _buildRow("Supplier",widget.purchase.supplierName),
            _buildRow("Location",widget.purchase.location),
            Divider(),
            ...widget.purchase.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
      
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // 🔹 Product Title
        Text(
          "Product ${index + 1}",
          style: AppTextStyles.formInputs15dark,
        ),
      
        const SizedBox(height: 6),
      
        _buildRow("Category", item.eggCategoryGrade),
        _buildRow("Quantity", item.trays.toString()),
        _buildRow("Rate", "₹ ${item.perEggPrice}"),
        _buildRow(
          "Total Eggs",
          (item.trays * item.capacity).toString(),
        ),
      
        const Divider(thickness: 1),
      ],
        );
      }).toList(),
             
              SizedBox(height: size.height*0.01),
            Text("Additional Costs",style: AppTextStyles.formInputs15dark,),
            _buildRow("Loading Charges", "₹ ${widget.purchase.loadingCharge}"),
      _buildRow("Unloading Charges", "₹ ${widget.purchase.unloadingCharge}"),
       //_buildRow("Transport", "₹ ${widget.purchase.transportCharge}"),
      _buildRow("Misc Expense", "₹ ${widget.purchase.miscExpense}"),
      _buildRow("Broker Fee", "₹ ${widget.purchase.brokerFee}"),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                Text(
                  "Total Additional Cost",
                  style: AppTextStyles.formInputs15dark,
                ),
                Text(
                 "₹ ${additionalTotal.toStringAsFixed(2)}",// placeholder
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
                  "₹ ${costPerTray.toStringAsFixed(2)}", // placeholder
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
                  style: AppTextStyles.headingText20,
                ),
                Text(
                  "₹ ${totalCost.toStringAsFixed(2)}", // placeholder
                  style: AppTextStyles.blueText2,
                ),
              ],
            ),
            
          Container(
            width: double.infinity,
            height: getHeight(context, 50),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: widget.isPaymentValid
      ? AppColors.amber600
      : Colors.grey.shade300,
              ),
            
            child: ElevatedButton(
            onPressed: !widget.isPaymentValid
      ? null
      : () {
      
          context.read<PurchaseBloc>().add(
            SubmitPurchaseEvent(purchase),
          );
      
        },
              style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
              ),
              child:context.watch<PurchaseBloc>().state
        is PurchaseSubmitting 
      ? SizedBox(
          height: getHeight(context, 24),
          width: getWidth(context, 24),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black,
          ),
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(Icons.lock_outline, color: AppColors.dark),
      
             SizedBox(width: getWidth(context, 8)),
      
            Text(
              "Pay",
              style: AppTextStyles.headingText20,
            ),
      
            SizedBox(width: getWidth(context, 8)),
      
            Text(
              "₹ ${totalCost.toStringAsFixed(2)}",
              style: AppTextStyles.headingText20,
            ),
          ],
        ),
            ),
          ),
          
          Container(
            width: double.infinity,
            height: getHeight(context, 50),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(5),
              color: AppColors.containerColor
              ),
            
            child: ElevatedButton(
              onPressed: () {
          
               
              },
              style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
              ),
              child:  
                  Text(
                          "Save cancel",
                          style: AppTextStyles.headingText20
                  ),
               
            ),
          ),
          Row(
            children: [
              Icon(Icons.info_outline,color: AppColors.textSecondary,),
              SizedBox(width: size.width*0.01,),
              Text("Stock will be marked as incoming upon\nsubmission",style: AppTextStyles.formInputs15),
            ],
          )
           
           
      
          ],
        ),
      ),
    );
  }

  
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