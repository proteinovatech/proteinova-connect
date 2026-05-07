import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_state.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/supplier_model.dart';

class SupplierLocationCard extends StatefulWidget {
   final Function(String supplier, String location,int supplierId) onChanged; 
  const SupplierLocationCard({super.key,required this.onChanged,});

  @override
  State<SupplierLocationCard> createState() =>
      _SupplierLocationCardState();
}

class _SupplierLocationCardState extends State<SupplierLocationCard> {
  String? selectedCompany;
  String location = "";
  bool isExpanded = false;
  List<SupplierModel> suppliers = [];


 
  @override
void initState() {
  super.initState();
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
          SizedBox(height: size.height*0.02),

             Text("Origin Location",style: AppTextStyles.buttonText16,),
    
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
          Text("Auto-filled based on selected supplier",style: AppTextStyles.bodyText14, )
          
        ],
      ]),
    );
  }
}