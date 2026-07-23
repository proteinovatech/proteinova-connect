import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/supplier/screens/add_suppliers.dart';
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
  final TextEditingController searchController = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<SupplierBloc>().add(FetchSuppliers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: 90,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Suppliers",
              style: TextStyle(
                fontSize: getFontSize(context, 22, tablet: 28),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 4),

            Text(
              "Manage your vendor relationships and track supply statuses",
              style: TextStyle(
                color: Colors.grey,
                fontSize: getFontSize(context, 12, tablet: 14),
              ),
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
                      builder: (context) => const AddSupplierScreen(),
                    ),
                  );

                  if (result == true) {
                    context.read<SupplierBloc>().add(FetchSuppliers());
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
                label: Text(
                  "Add Supplier",
                  style: TextStyle(
                    fontSize: getFontSize(context, 13, tablet: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SupplierBloc>().add(FetchSuppliers());
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
                          children: [
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
                                  hintStyle: TextStyle(
                                    fontSize: getFontSize(
                                      context,
                                      13,
                                      tablet: 15,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontSize: getFontSize(
                                    context,
                                    13,
                                    tablet: 15,
                                  ),
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
                  SizedBox(height: getHeight(context, 16)),
                  BlocBuilder<SupplierBloc, SupplierState>(
                    builder: (context, state) {
                      if (state is SupplierLoading) {
                        return const SupplierShimmer();
                      }

                      if (state is SupplierError) {
                        return Center(child: Text(state.message));
                      }

                      if (state is SupplierLoaded) {
                        final suppliers = state.suppliers;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: suppliers.length,
                          itemBuilder: (context, index) {
                            final supplier = suppliers[index];

                            return PurchaseCards(
                              status: supplier.status,

                              statusColor: AppColors.green,

                              textColor: Colors.white,

                              supplier: supplier.companyName,

                              orderId: "SUP-${supplier.id}",

                              location: supplier.location,

                              email: supplier.email,

                              items: "Supplier Details",

                              itemboxes: supplier.status,

                              contactperson: supplier.supplierName,

                              contactnumber: supplier.phoneNumber,

                              onEdit: () async {
                                print("GST: ${supplier.gstNumber}");
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddSuppliers(supplier: supplier),
                                  ),
                                );

                                if (updated == true) {
                                  context.read<SupplierBloc>().add(
                                    FetchSuppliers(),
                                  );
                                }
                              },
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
            child: Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: const Text(
                  "Active",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
  final String location;
  final String email;
  final String items;
  final String itemboxes;
  final String contactperson;
  final String contactnumber;
  final VoidCallback? onEdit;

  const PurchaseCards({
    super.key,
    required this.status,
    required this.statusColor,
    required this.textColor,
    required this.supplier,
    required this.orderId,
    required this.location,
    required this.email,
    required this.items,
    required this.itemboxes,
    required this.contactperson,
    required this.contactnumber,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: getHeight(context, 16)),
      padding: EdgeInsets.all(getWidth(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(getWidth(context, 18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: getWidth(context, 12),
            offset: Offset(0, getHeight(context, 4)),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Left Circle
          Container(
            width: getWidth(context, 52),
            height: getWidth(context, 52),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                orderId,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: getFontSize(context, 11, tablet: 13),
                ),
              ),
            ),
          ),

          SizedBox(width: getWidth(context, 16)),

          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier,
                  style: AppTextStyles.headingText16.copyWith(
                    fontSize: getFontSize(context, 16, tablet: 20),
                  ),
                ),

                SizedBox(height: getHeight(context, 4)),

                Text(
                  contactperson,
                  style: AppTextStyles.bodyText14.copyWith(
                    fontSize: getFontSize(context, 13, tablet: 15),
                  ),
                ),

                SizedBox(height: getHeight(context, 4)),

                Text(
                  (contactnumber == null ||
                          contactnumber.toString().trim().isEmpty)
                      ? "--"
                      : contactnumber.toString(),
                  style: AppTextStyles.bodyText14,
                ),

                SizedBox(height: getHeight(context, 4)),

                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyText14,
                ),

                SizedBox(height: getHeight(context, 4)),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: getFontSize(context, 16, tablet: 18),
                      color: Colors.black,
                    ),

                    SizedBox(width: getWidth(context, 3)),

                    Text(location, style: AppTextStyles.bodyText14),

                    const Spacer(),

                    StatusBadge(
                      text: status,
                      bgColor: Colors.green.shade100,
                      textColor: Colors.green,
                    ),

                    SizedBox(width: getWidth(context, 3)),

                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(getWidth(context, 8)),
                      child: Icon(
                        Icons.edit_outlined,
                        size: getFontSize(context, 18, tablet: 20),
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: getWidth(context, 12)),

          /// Right Icon
          Container(
            width: getWidth(context, 35),
            height: getWidth(context, 35),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(getWidth(context, 14)),
            ),
            child: Icon(
              Icons.store_outlined,
              color: AppColors.amber600,
              size: getFontSize(context, 22, tablet: 26),
            ),
          ),
        ],
      ),
    );
  }
}
