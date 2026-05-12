import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/presentation/add_supplier_screen.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/editbutton.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/statusbadge.dart';
import 'package:proteinova_connect/features/admin/supplier/services/supplier_service.dart';
import 'package:proteinova_connect/features/admin/supplier/models/supplier_model.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final SupplierService _supplierService = SupplierService();
  List<Supplier> _suppliers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final suppliers = await _supplierService.getSuppliers();
      if (!mounted) return;
      setState(() {
        _suppliers = suppliers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddSupplierScreen(),
                    ),
                  );

                  if (result == true) {
                    _fetchSuppliers();
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Error: $_error"),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _fetchSuppliers,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : _suppliers.isEmpty
                    ? const Center(child: Text("No suppliers found"))
                    : RefreshIndicator(
                        onRefresh: _fetchSuppliers,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),

                                /// SEARCH
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      height: 45,
                                      width: 175,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                          ),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      height: 45,
                                      width: 95,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
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
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      height: 45,
                                      width: 55,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.file_download_outlined),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ..._suppliers.map(
                                  (supplier) => PurchaseCards(
                                    status:
                                        supplier.active ? "Active" : "Inactive",
                                    statusColor:
                                        supplier.active
                                            ? Colors.green
                                            : Colors.grey,
                                    textColor: Colors.white,
                                    supplier: supplier.name,
                                    orderId: 'ID: ${supplier.id}',
                                    dateTime: '', // Not available in model
                                    bottomId: '',
                                    items: '',
                                    itemboxes: '',
                                    contactperson: supplier.owner,
                                    contactnumber: supplier.phone,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 10),
          Text(contactnumber, style: AppTextStyles.headingText22),

          /// 🔹 EDIT BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              EditButton(),
            ],
          ),
        ],
      ),
    );
  }
}
