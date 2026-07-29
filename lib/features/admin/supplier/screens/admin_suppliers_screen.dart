import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_expense_management_skeleton_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/supplier/widgets/add_supplier_bottom_sheet.dart';
import 'package:proteinova_connect/features/admin/supplier/bloc/supplier_bloc.dart';

import '../data/models/supplier_model.dart';
import '../data/services/supplier_service.dart';

import '../widgets/supplier_card_admin.dart';

class AdminSuppliersScreen extends StatefulWidget {
  const AdminSuppliersScreen({super.key});

  @override
  State<AdminSuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<AdminSuppliersScreen> {
  int selectedBottomIndex = 0;

  final TextEditingController searchController = TextEditingController();
  final SupplierService _supplierService = SupplierService();
  List<Supplier> suppliers = [];

  List<Supplier> filteredSuppliers = [];

  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(FetchSuppliersEvent());
  }

  void searchSupplier(String value) {
    setState(() {
      filteredSuppliers = suppliers.where((supplier) {
        return supplier.name.toLowerCase().contains(value.toLowerCase()) ||
            supplier.location.toLowerCase().contains(value.toLowerCase()) ||
            supplier.owner.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  void addSupplier() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddSupplierBottomSheet();
      },
    ).then((_) {
      context.read<SupplierBloc>().add(
        FetchSuppliersEvent(),
      ); // Refresh after adding
    });
  }

  void editSupplier(Supplier supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddSupplierBottomSheet(supplierToEdit: supplier);
      },
    ).then((_) {
      context.read<SupplierBloc>().add(
        FetchSuppliersEvent(),
      ); // Refresh after editing
    });
  }

  void deleteSupplier(Supplier supplier) async {
    try {
      if (supplier.id.isNotEmpty) {
        await _supplierService.deleteSupplier(supplier.id);
      }
      setState(() {
        suppliers.remove(supplier);
        filteredSuppliers.remove(supplier);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${supplier.name} Deleted")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete supplier: $e")));
    }
  }

  void showMoreOptions(Supplier supplier) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  editSupplier(supplier);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  deleteSupplier(supplier);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void filterAction() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Filter Clicked")));
  }

  void downloadAction() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Download Clicked")));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupplierBloc, SupplierState>(
      listener: (context, state) {
        if (state is SupplierError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },

      builder: (context, state) {
        List<dynamic> filteredSuppliers = [];

        if (state is SupplierLoaded) {
          filteredSuppliers = state.filteredSuppliers;
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: state is SupplierLoading
              ? const AdminExpenseManagementSkeletonLoader()
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<SupplierBloc>().add(FetchSuppliersEvent());
                  },
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(context, 16),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: getHeight(context, 10)),

                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  "Suppliers",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffF4C400),
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: addSupplier,
                                icon: const Icon(Icons.add),
                                label: const Text("Add Supplier"),
                              ),
                            ],
                          ),

                          SizedBox(height: getHeight(context, 14)),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Manage your vendor relationships and\ntrack supply statuses.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),

                          SizedBox(height: getHeight(context, 20)),

                          // Container(
                          //   padding: EdgeInsets.symmetric(
                          //     horizontal: getWidth(context, 12),
                          //     vertical: getHeight(context, 12),
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       Expanded(
                          //         child: TextField(
                          //           controller: searchController,
                          //           onChanged: searchSupplier,
                          //           decoration: InputDecoration(
                          //             hintText: "Filter suppliers...",
                          //             prefixIcon: const Icon(Icons.search),
                          //             border: OutlineInputBorder(
                          //               borderRadius: BorderRadius.circular(14),
                          //             ),
                          //           ),
                          //         ),
                          //       ),

                          //       SizedBox(width: getWidth(context, 10)),

                          //       InkWell(
                          //         onTap: filterAction,
                          //         child: Container(
                          //           padding: EdgeInsets.symmetric(
                          //             horizontal: getWidth(context, 16),
                          //             vertical: getHeight(context, 16),
                          //           ),
                          //           decoration: BoxDecoration(
                          //             border: Border.all(
                          //               color: Colors.grey.shade300,
                          //             ),
                          //             borderRadius: BorderRadius.circular(14),
                          //           ),
                          //           child: const Icon(Icons.filter_alt_outlined),
                          //         ),
                          //       ),

                          //       SizedBox(width: getWidth(context, 10)),

                          //       InkWell(
                          //         onTap: downloadAction,
                          //         child: Container(
                          //           padding: EdgeInsets.symmetric(
                          //             horizontal: getWidth(context, 16),
                          //             vertical: getHeight(context, 16),
                          //           ),
                          //           decoration: BoxDecoration(
                          //             border: Border.all(
                          //               color: Colors.grey.shade300,
                          //             ),
                          //             borderRadius: BorderRadius.circular(14),
                          //           ),
                          //           child: const Icon(Icons.download),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(height: getHeight(context, 20)),

                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredSuppliers.length,
                              itemBuilder: (context, index) {
                                final supplier = filteredSuppliers[index];

                                return SupplierCardAdmin(
                                  supplier: supplier,
                                  onEdit: () => editSupplier(supplier),
                                  onMore: () => showMoreOptions(supplier),
                                );
                              },
                            ),
                          ),

                          Row(
                            children: [
                              Text(
                                "Showing ${filteredSuppliers.length} records",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),

                          SizedBox(height: getHeight(context, 12)),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: getHeight(context, 50),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(child: Text("Previous")),
                                ),
                              ),
                              SizedBox(width: getWidth(context, 12)),
                              Expanded(
                                child: Container(
                                  height: getHeight(context, 50),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Next",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: getHeight(context, 10)),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
