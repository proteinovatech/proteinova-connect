import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch_dashboard/presentation/add_supplier_screen.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/editbutton.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/statusbadge.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff5f6fa),
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
                      builder: (context) => const AddSupplierScreen(),
                    ),
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
          ),
        ],
      ),
      backgroundColor: const Color(0xfff5f6fa),
      body: SafeArea(
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
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Filter Supplier...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * 0.09),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 45,
                      width: 95,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.filter_alt_outlined),
                          SizedBox(width: 1),
                          Expanded(child: Text("Filter")),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 45,
                      width: 55,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [Icon(Icons.file_download_outlined)],
                      ),
                    ),
                  ],
                ),
                PurchaseCards(
                  status: "Active",
                  statusColor: Colors.green,
                  textColor: Colors.white,
                  supplier: "Apex Farms",
                  orderId: 'PO-1024',
                  dateTime: 'Today, 10.45 PM',
                  bottomId: '\$7,500.00',
                  items: 'Jumbo White(Grade AA)',
                  itemboxes: '500 Boxes',
                  contactperson: 'Robert',
                  contactnumber: '+91 1234567890',
                ),
                SizedBox(height: 10),
                PurchaseCards(
                  status: "Active",
                  statusColor: Colors.green,
                  textColor: Colors.white,
                  supplier: "Golden",
                  orderId: 'PO-1025',
                  dateTime: 'Today, 10.45 PM',
                  bottomId: '\$8,500.00',
                  items: 'Jumbo White(Grade AA)',
                  itemboxes: '500 Boxes',
                  contactperson: 'James',
                  contactnumber: '+91 1234567890',
                ),
                SizedBox(height: 10),
                PurchaseCards(
                  status: "Active",
                  statusColor: Colors.green,
                  textColor: Colors.white,
                  supplier: "MR.D ",
                  orderId: 'PO-1026',
                  dateTime: 'Today, 10.45 PM',
                  bottomId: '\$6,500.00',
                  items: 'Jumbo White(Grade AA)',
                  itemboxes: '500 Boxes',
                  contactperson: 'David kim',
                  contactnumber: '+91 1234567890',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                isActive ? "Active" : "Inactive",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey.shade700,
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          /// 🔹 STATUS
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
          Text(supplier, style: AppTextStyles.headingText22),
          Text(orderId, style: AppTextStyles.headingText20),

          // Text(dateTime, style: AppTextStyles.bodyText16),
          const SizedBox(height: 30),
          Divider(color: Colors.grey.shade300),

          /// 🔹 SUPPLIER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.store_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Text(contactperson, style: AppTextStyles.bodyText16),
            ],
          ),
          SizedBox(height: 10),
          Text(contactnumber, style: AppTextStyles.headingText22),

          // Text(itemboxes, style: AppTextStyles.bodyText16),
          // const SizedBox(height: 50),
          // Divider(color: Colors.grey.shade300),

          /// 🔹 EDIT BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Text(bottomId, style: AppTextStyles.headingText22),
              const EditButton(),
            ],
          ),
        ],
      ),
    );
  }
}
