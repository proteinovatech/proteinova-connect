import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_state.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/supplier_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/add_supplier_pop.dart';

class SupplierLocationCard extends StatefulWidget {
  final Function(String supplier, String location, int supplierId) onChanged;
  final TextEditingController brokerNameController;
  final TextEditingController brokerNumController;
  final DateTime? initialDate;
  final Function(DateTime? date) onDateChanged;

  const SupplierLocationCard({
    super.key,
    required this.onChanged,
    required this.brokerNameController,
    required this.brokerNumController,
    required this.onDateChanged,
    this.initialDate,
  });

  @override
  State<SupplierLocationCard> createState() =>
      _SupplierLocationCardState();
}

class _SupplierLocationCardState extends State<SupplierLocationCard> {
  String? selectedCompany;
  String location = "";
  bool isExpanded = false;
  DateTime? deliveryDate;
  List<SupplierModel> suppliers = [];

  @override
  void initState() {
    super.initState();
    deliveryDate = widget.initialDate;
    context.read<SupplierBloc>().add(FetchSuppliers());
  }

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

          BlocBuilder<SupplierBloc, SupplierState>(
  builder: (context, state) {
    if (state is SupplierLoading) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: LinearProgressIndicator(),
      );
    }

    if (state is SupplierLoaded) {
      suppliers = state.suppliers;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.containerColor,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
             SizedBox(width: size.width * 0.02),
            Icon(Icons.store_outlined, color: AppColors.light),
            SizedBox(width: size.width * 0.02),

            Expanded(
              child: DropdownButton<String>(
                value: selectedCompany,
                isExpanded: true,
                hint: const Text("Select Supplier"),
                underline: const SizedBox(),

                items: suppliers.map((supplier) {
                  return DropdownMenuItem(
                    value: supplier.companyName,
                    child: Text(supplier.companyName),
                  );
                }).toList(),

                onChanged: (value) {
                  final selected = suppliers.firstWhere(
                    (e) => e.companyName == value,
                  );

                  setState(() {
                    selectedCompany = value;
                    location = selected.location;
                  });

                  widget.onChanged(
                    selected.companyName,
                    selected.location,
                    selected.id
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    if (state is SupplierError) {
      return Text(state.message);
    }

    return const SizedBox();
  },
),
 SizedBox(height: size.height*0.01),

Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton.icon(
                  // onPressed: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const AddSupplierScreen(),
                  //     ),
                  //   );
                  // },
                  onPressed: () async {
                     final result = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AddSupplierPopup(),
  );
  
                    if (result != null) {
                      print(result["supplier"]);
                      print(result["contactperson"]);
  
                      /// here add your card list update logic
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfffacc15),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Supplier"),
                ),
),
          SizedBox(height: size.height*0.01),

             Text("Origin Location",style: AppTextStyles.buttonText16,),
    
          SizedBox(height: getHeight(context, 6)),

          
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
                 SizedBox(width: size.width * 0.02),
                Icon(Icons.location_on_outlined, color: AppColors.light),
    SizedBox(width: size.width * 0.02),

    Expanded(
      child: Text(
        location.isEmpty
            ? "Auto-filled location"
            : location,
        style: AppTextStyles.formInputs15,
        overflow: TextOverflow.ellipsis,
      ),
    ),

    const Icon(
      Icons.check_circle_outline,
      color: AppColors.green,
    ),
     
              ],
            ),
          ),
          SizedBox(height:size.height*0.01),
          Text("Auto-filled based on selected supplier",style: AppTextStyles.bodyText14, ),

           SizedBox(height: size.height*0.02),

             Text("Broker Name",style: AppTextStyles.buttonText16,),
             SizedBox(height: getHeight(context, 6)),

             Container(  
             padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.containerColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.border),
            ),child: TextField(
               controller: widget.brokerNameController, 
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.person_outlined,color: AppColors.light,),
      hintText: "Enter broker name",
      border: InputBorder.none,
    ),
            ),
            ),
               SizedBox(height: size.height*0.02),

             Text("Broker Contact Number",style: AppTextStyles.buttonText16,),
             SizedBox(height: getHeight(context, 6)),

             Container(  
             padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.containerColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.border),
            ),child: TextField(
               controller: widget.brokerNumController,
                 keyboardType: TextInputType.number, 
                  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.phone_outlined,color:AppColors.light,),
      hintText: "Enter broker number",
      border: InputBorder.none,
    ),
            ),
            ),
            SizedBox(height: size.height*0.02),
             const Text("Expected Arrival Date",
                style: AppTextStyles.buttonText16),
            SizedBox(height: getHeight(context, 6)),

            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    deliveryDate = picked;
                  });
                  widget.onDateChanged(picked);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.containerColor,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(width: size.width*0.02,),
                    Icon(Icons.calendar_today_outlined,color:AppColors.textSecondary),
                    SizedBox(width: getWidth(context, 20)),
                    Text(
                      deliveryDate == null
                          ? "Select Delivery Date"
                          : deliveryDate.toString().split(" ")[0],
                    ),
                  ],
                ),
              ),
            ),

          
          
        ],
      ]),
    );
  }
}