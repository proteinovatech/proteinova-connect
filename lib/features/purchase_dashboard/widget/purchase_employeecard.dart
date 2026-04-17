import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class PurchaseEmployeecard extends StatefulWidget {
  final TextEditingController branchController;
  final TextEditingController numberController;
  final TextEditingController typeController;
  final TextEditingController contactController;
  final TextEditingController notesController;
  const PurchaseEmployeecard({super.key,
  required this.branchController,
  required this.numberController,
  required this.typeController,
  required this.contactController,
  required this.notesController,
  });

  @override
  State<PurchaseEmployeecard> createState() =>
      _PurchaseEmployeecardState();
}

class _PurchaseEmployeecardState extends State<PurchaseEmployeecard> {
  String? selectedSupplier;
  String location = "";
  bool isExpanded=false;

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
                    "Purchase Employee Details",
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
          const Text("Driver Name",style: AppTextStyles.buttonText16,),

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
                Icon(Icons.person_outline, color: AppColors.light), 
                 SizedBox(width: size.width*0.02),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSupplier,
                    isExpanded: true,
                    hint: const Text("Select Name"),
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
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: size.height*0.02),

          Text("Reaching Warehouse",style: AppTextStyles.buttonText16,),
             
           const SizedBox(height: 6),

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
                Icon(Icons.store_outlined, color: AppColors.light),
                 SizedBox(width: size.width*0.02),
                Text(
                  "Branch name",
                  style: AppTextStyles.formInputs15,
                ),
                 SizedBox(width: size.width*0.26),
                Icon(Icons.check_circle_outline, color: AppColors.green),
     
              ],
            ),
          ),
           SizedBox(height: size.height*0.02),

          Text("Vehicle Number",style: AppTextStyles.buttonText16,),
             
           const SizedBox(height: 6),
           _buildField(
            controller:widget.numberController , 
            hint: "Enter number"),

             SizedBox(height: size.height*0.02),

            Text("Vehicle Type",style: AppTextStyles.buttonText16,),
             
           const SizedBox(height: 6),
           _buildField(
            controller:widget.typeController , 
            hint: "Enter type"),

             SizedBox(height: size.height*0.02),

            Text("Driver Contact Number",style: AppTextStyles.buttonText16,),
             
           const SizedBox(height: 6),
           _buildField(
            controller:widget.contactController , 
            hint: "Enter contact no",
            isNumeric: true),

             SizedBox(height: size.height*0.02),

            Text("Additional Procurement Notes",style: AppTextStyles.buttonText16,),
             
           const SizedBox(height: 6),
           _buildField(
            controller:widget.notesController , 
            hint: "Add any notes regarding quality,transport\nconditions or special instructions...",
            maxLines: 3,
            height: 100,
            )
          
          
        ],
      ]),
    );
  }
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    int maxLines = 1,
     IconData? icon,
      double? height,
     bool isNumeric = false, 
     String? prefixText, // 👈 add this
  }) {
    return Container(
       height:height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.containerColor,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: AppTextStyles.formInputs15,
         keyboardType:
          isNumeric ? TextInputType.number : TextInputType.text, // 👈

      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.digitsOnly] // 👈 only numbers
          : [],
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.light) : null,
          prefixText: prefixText
        ),
      ),
    );
  }
}