import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/branch/customer_trays/data/model/customer_tray_model.dart';
import 'package:proteinova_connect/features/branch/customer_trays/data/service/customer_tray_service.dart';
import 'package:proteinova_connect/features/branch/customer_trays/presentation/customer_tray_ledger_shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CustomerTrayEvent {}
abstract class CustomerTrayState {}

class CustomerTrayInitial extends CustomerTrayState {}

class CustomerTrayLoading extends CustomerTrayState {}

class CustomerTrayLoaded extends CustomerTrayState {
  final List<CustomerTray> trays;

  CustomerTrayLoaded(this.trays);
}
class CustomerTrays extends StatefulWidget {
  
  
  const CustomerTrays({super.key});

  @override
  State<CustomerTrays> createState() => _CustomerTraysState();
}

class _CustomerTraysState extends State<CustomerTrays> {
  
 
  
  final TextEditingController searchController =
    TextEditingController();

CustomerTray? selectedTray;
  Future<void> fetchCustomerTrays({String search = ''}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final branchId =
        prefs.getInt("branch_id") ?? 1;
    final result =
        await CustomerTrayService.getCustomerTrays(
      branchId: branchId,
      search: search,
    );
    setState(() {
      trays = result;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    debugPrint(e.toString());
  }
}
  List<CustomerTray> trays = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
       final prefs = await SharedPreferences.getInstance();

    final branchId =
        prefs.getInt("branch_id") ?? 1;

      final result =
          await CustomerTrayService.getCustomerTrays(
        branchId: branchId,
      );
      setState(() {
        trays = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
     if (isLoading) {
    return const CustomerTrayLedgerShimmer();
  }
    return Scaffold(
        backgroundColor: AppColors.background1,
            body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25,),
          Row(
  children: [
    IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        Icons.arrow_back_ios_new,
        size: 20,
      ),
    ),

    const Icon(
      Icons.inventory_2_outlined,
      size: 20,
      color: Colors.orange,
    ),

    const SizedBox(width: 8),

    const Text(
      "Customer Trays Ledger",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
),  const SizedBox(height: 4),
                    Text(
              "Track empty trays given to customers during sale.",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
                    const SizedBox(height: 20),
                    SizedBox(
              width: double.infinity,
              height: 40,
              child: Autocomplete<CustomerTray>(
  displayStringForOption: (tray) =>
      "${tray.customerName} (${tray.customerNumber})",

  optionsBuilder: (TextEditingValue textEditingValue) {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<CustomerTray>.empty();
    }
    return trays.where((tray) {
      return tray.customerName
              .toLowerCase()
              .contains(
                textEditingValue.text.toLowerCase(),
              ) ||
          tray.customerNumber.contains(
            textEditingValue.text,
          );
    });
  },

  onSelected: (CustomerTray tray) {
    setState(() {
      selectedTray = tray;
    });
  },

  fieldViewBuilder: (
    context,
    controller,
    focusNode,
    onFieldSubmitted,
  ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText:
            "Search by customer name or mobile...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  },
) ),
        
           Expanded(
  child: isLoading
      ? const CustomerTrayLedgerShimmer()
      : trays.isEmpty
          ? const Center(
              child: Text("No tray records found"),
            )
          : ListView.builder(
              itemCount: trays.length,
              itemBuilder: (context, index) {
                final tray = trays[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      /// Customer Name & Location
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              tray.customerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            tray.soldLocation,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _detailRow(
                        "Mobile",
                        tray.customerNumber,
                      ),

                      _detailRow(
                        "Tray Type",
                        tray.trayType,
                      ),

                      _detailRow(
                        "Given",
                        tray.traysGiven.toString(),
                      ),

                      _detailRow(
                        "Returned",
                        tray.traysReturned.toString(),
                      ),

                      _detailRow(
                        "Balance",
                        tray.balance.toString(),
                      ),
                    ],
                  ),
                );
              },
            ),
) ]),)
    );
  }

Widget _buildRow({
  required String customerName,
  required String mobile,
  required String location,
  required String trayType,
  required String given,
  required String returned,
  required String balance,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Expanded(child: Text(customerName)),
        Expanded(child: Text(location)),
        Expanded(child: Text(trayType)),
        Expanded(child: Text(given)),
        Expanded(child: Text(returned)),
        Expanded(child: Text(balance)),
      ],
    ),
  );
}
Widget _detailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            "$title :",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
}