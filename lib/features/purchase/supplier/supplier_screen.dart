import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_state.dart';

import 'package:proteinova_connect/features/purchase/supplier/add_supplier_screen.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/statusbadge.dart';
import 'package:proteinova_connect/features/purchase/supplier/widget/supplier_shimmer.dart';


class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
 final TextEditingController searchController =
    TextEditingController(); 
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  context.read<SupplierBloc>().add(
        FetchSuppliers(),
      );
}




 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor:AppColors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: 90,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Suppliers",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 4),

            Text(
              "Manage your vendor relationships and track supply statuses",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
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
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const AddSupplierScreen(),
    ),
  );

  if (result == true) {
    context.read<SupplierBloc>().add(
      FetchSuppliers(),
    );
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
          ),
        ],
      ),
      backgroundColor:AppColors.background,
      body: RefreshIndicator(
         onRefresh: () async {
  context.read<SupplierBloc>().add(
  FetchSuppliers(),
);
  },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
        
                  /// SEARCH
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 45,
                        width: 175,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children:  [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 10),
                           Expanded(
  child: TextField(
  onChanged: (value) {
  context.read<SupplierBloc>().add(
        SearchSupplierEvent(value),
      );
},

  decoration: InputDecoration(
    hintText: "Filter Supplier...",
    border: InputBorder.none,
  ),
),
),
                          ],
                        ),
                      ),
                      // SizedBox(width: size.width * 0.09),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 12),
                      //   height: 45,
                      //   width: 95,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.grey.shade300),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Row(
                      //     children: const [
                      //       Icon(Icons.filter_alt_outlined),
                      //       SizedBox(width: 1),
                      //       Expanded(child: Text("Filter")),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(width: 10),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 12),
                      //   height: 45,
                      //   width: 55,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.grey.shade300),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Row(
                      //     children: const [Icon(Icons.file_download_outlined)],
                      //   ),
                      // ),
                    ],
                  ),
                BlocBuilder<SupplierBloc, SupplierState>(
  builder: (context, state) {

    if (state is SupplierLoading) {
      return const SupplierShimmer();
    }

    if (state is SupplierError) {
      return Center(
        child: Text(state.message),
      );
    }

    if (state is SupplierLoaded) {

      final suppliers = state.suppliers;

      return ListView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: suppliers.length,
        itemBuilder: (context, index) {

          final supplier = suppliers[index];

          return PurchaseCards(
            status: supplier.status,

            statusColor:
                 AppColors.green,
                    

            textColor: Colors.white,

            supplier:
                supplier.companyName,

            orderId:
                "ID-${index + 1}",

            dateTime:
                supplier.location,

            bottomId:
                supplier.email,

            items:
                "Supplier Details",

            itemboxes:
                supplier.status,

            contactperson:
                supplier.supplierName,

            contactnumber:
                supplier.phoneNumber,
          );
        },
      );
    }

    return const SizedBox();
  },
),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSupplierRow({
    required String supplier,
    required String id,
    required String location,
    required String person,
    required String phone,
    required String email,
    required bool isActive,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          /// SUPPLIER
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  id,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),

          /// LOCATION
          Expanded(child: Text(location, style: const TextStyle(fontSize: 13))),

          /// CONTACT PERSON
          Expanded(child: Text(person, style: const TextStyle(fontSize: 13))),

          /// CONTACT INFO
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phone, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          /// STATUS
          Expanded(
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(0.1),
      borderRadius: BorderRadius.circular(30),
    ),
    child: const Text(
      "Active",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.green,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

          /// ACTIONS
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class PurchaseCards extends StatelessWidget {
  final String status;
  final Color statusColor;
  final Color textColor;
  final String supplier;

  final String orderId;
  final String dateTime;
  final String bottomId;
  final String items;
  final String itemboxes;
  final String contactperson;
  final String contactnumber;

  const PurchaseCards({
    super.key,
    required this.status,
    required this.statusColor,
    required this.textColor,
    required this.supplier,
    required this.orderId,
    required this.dateTime,
    required this.bottomId,
    required this.items,
    required this.itemboxes,
    required this.contactperson,
    required this.contactnumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StatusBadge(
                text: status,
                bgColor: statusColor,
                textColor: textColor,
              ),
            ],
          ),

          /// COMPANY NAME
          Text(
            supplier,
            style: AppTextStyles.headingText22,
          ),

          const SizedBox(height: 4),

          /// ORDER ID
          Text(
            orderId,
            style: AppTextStyles.bodyText16,
          ),

          const SizedBox(height: 6),

          /// LOCATION
          Text(
            dateTime,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          Divider(color: Colors.grey.shade300),

          const SizedBox(height: 14),

          /// CONTACT PERSON
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  contactperson,
                  style: AppTextStyles.bodyText16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// PHONE
          Text(
            contactnumber,
            style: AppTextStyles.headingText22,
          ),

          const SizedBox(height: 8),

          /// EMAIL
          Text(
            bottomId,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 18),

          /// EXTRA DETAILS
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      items,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      itemboxes,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
