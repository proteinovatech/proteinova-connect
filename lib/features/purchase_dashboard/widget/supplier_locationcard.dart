import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class SupplierLocationCard extends StatefulWidget {
   final Function(String supplier, String location) onChanged; 
  const SupplierLocationCard({super.key,required this.onChanged,});

  @override
  State<SupplierLocationCard> createState() =>
      _SupplierLocationCardState();
}

class _SupplierLocationCardState extends State<SupplierLocationCard> {
  String? selectedSupplier;
  String location = "";
  bool isExpanded = false;

  // Dummy data (replace with API/Supabase later)
  final Map<String, String> supplierData = {
    "ABC Suppliers": "Kerala",
    "XYZ Traders": "Tamil Nadu",
    "Global Exports": "Karnataka",
  };

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Main Title
           InkWell(
             onTap: () {
    setState(() {
      isExpanded = !isExpanded;
    });
  },
             child: Row(
               children: [
                Icon(Icons.local_shipping_outlined,color: AppColors.blueAccent,),
                 SizedBox(width: size.width*0.02),
                 Expanded(
                   child: Text(
                    "Supplier & Location Details",
                    style: AppTextStyles.headingText20,
                             ),
                 ),
                 Icon(
        isExpanded
            ? Icons.keyboard_arrow_up
            : Icons.keyboard_arrow_down,
      ),
               ],
             ),
           ),

          if(isExpanded)...[SizedBox(height:size.height*0.01 ),

          const Divider(color: AppColors.border,),

          SizedBox(height: size.height*0.01),

          // 🔹 Supplier Name Title
          const Text("Supplier Name",style: AppTextStyles.buttonText16,),

          SizedBox(height:size.height*0.01),

          // 🔽 Dropdown Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.containerColor,
              border: Border.all(color:AppColors.border),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Icon(Icons.store_outlined, color: AppColors.light), 
                 SizedBox(width: size.width*0.02),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSupplier,
                    isExpanded: true,
                    hint: const Text("Select Supplier"),
                    underline: const SizedBox(),
                    items: supplierData.keys.map((supplier) {
                      return DropdownMenuItem(
                        value: supplier,
                        child: Text(supplier),
                      );
                    }).toList(),
                    onChanged: (value) {
  setState(() {
    selectedSupplier = value;
    location = supplierData[value] ?? "";
  });

  widget.onChanged(selectedSupplier ?? "", location); 
},
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: size.height*0.02),

          
             Text("Origin Location",style: AppTextStyles.buttonText16,),
             
            
         

          const SizedBox(height: 6),

          // 📍 Auto-filled Location Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.containerColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.light),
                 SizedBox(width: size.width*0.02),
                Text(
                  location.isEmpty ? "Auto-filled location" : location,
                  style: AppTextStyles.formInputs15,
                ),
                 SizedBox(width: size.width*0.23),
                Icon(Icons.check_circle_outline, color: AppColors.green),
     
              ],
            ),
          ),
          SizedBox(height:size.height*0.01),
          Text("Auto-filled based on selected supplier",style: AppTextStyles.bodyText14, )
          
        ],
      ]),
    );
  }
}