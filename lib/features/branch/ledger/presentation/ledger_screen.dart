import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/ledger/bloc/ledger_bloc.dart';
import 'package:proteinova_connect/features/branch/ledger/bloc/ledger_event.dart';
import 'package:proteinova_connect/features/branch/ledger/bloc/ledger_state.dart';
import 'package:proteinova_connect/features/branch/ledger/data/model/branch_ledger_model.dart';
import 'package:proteinova_connect/features/branch/ledger/data/model/ledger_model.dart';
import 'package:proteinova_connect/features/branch/ledger/presentation/ledger_shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});
  @override
  State<LedgerScreen> createState() => _LedgerScreenState();

  static Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 4), // Horizontal, Vertical
      ),
    ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(value, style: AppTextStyles.headingText16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dropdown(
    String hint,
    String? value,
    List<DropdownMenuItem<String>> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _LedgerScreenState extends State<LedgerScreen> {
  

  bool isLoading = true;
  String error = '';
  String userBranch = "KRPURAM"; // later you can replace dynamically
  double totalOutstanding = 0;
  double totalCharged = 0;
  double totalReceived = 0;
  int pendingCustomers = 0;
  int clearedCustomers = 0;
  int loggedBranchId = 0;

  final inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  final TextEditingController searchController = TextEditingController();
  final formatter = NumberFormat('#,##0.00');
  List<dynamic> filteredCustomers = [];

  String selectedLocation = "all";
  String selectedBranch = "all";
  String selectedStatus = "all";

  List<dynamic> customers = [];
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static const double customerWidth = 250;
  static const double phoneWidth = 150;
  static const double locationWidth = 150;
  static const double chargedWidth = 150;
  static const double paidWidth = 150;
  static const double balanceWidth = 150;
  static const double statusWidth = 120;
  static const double lastTxnWidth = 180;
  static const double tableWidth =
      customerWidth +
      phoneWidth +
      locationWidth +
      chargedWidth +
      paidWidth +
      balanceWidth +
      statusWidth +
      lastTxnWidth;
  @override
  void initState() {
    super.initState();
    loadBranchId().then((_) {
    context.read<LedgerBloc>().add(FetchLedgerEvent());
  });
  }
  Future<void> loadBranchId() async {
  final prefs = await SharedPreferences.getInstance();

  loggedBranchId = prefs.getInt("branch_id") ?? 0;
}

  void searchCustomer() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredCustomers = List.from(customers);
      } else {
        filteredCustomers = customers.where((customer) {
          final name =
              customer['customer_name']?.toString().toLowerCase() ?? '';

          return name.contains(query);
        }).toList();
      }
    });
  }

  void applyFilters() {
    setState(() {
      filteredCustomers = customers.where((customer) {
        bool matchesLocation = true;
        bool matchesBranch = true;
        bool matchesStatus = true;

        // Location filter
        if (selectedLocation != "all") {
          matchesLocation =
              customer['location_type']?.toString().toLowerCase() ==
              selectedLocation;
        }

        // Branch filter
        if (selectedBranch != "all") {
          matchesBranch =
              customer['sold_location']?.toString().toLowerCase() ==
              selectedBranch.toLowerCase();
        }

        // Status filter
        if (selectedStatus != "all") {
          matchesStatus =
              customer['status']?.toString().toLowerCase() == selectedStatus;
        }

        return matchesLocation && matchesBranch && matchesStatus;
      }).toList();
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor:Colors.white,
    body: BlocBuilder<LedgerBloc, LedgerState>(
      builder: (context, state) {
        if (state is LedgerLoading) {
          return const LedgerShimmer();
        }

        if (state is LedgerError) {
          return Center(
            child: Text(state.message),
          );
        }

        if (state is LedgerLoaded) {
          return _buildContent(context, state.ledger);
        }

        return const SizedBox();
      },
    ),
  );
}
 Widget _buildContent(BuildContext context, LedgerModel ledger) {
   final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 56) / 2;
     final summary = ledger.summary;

 String userBranch = "";

for (final branch in ledger.branches) {
  if (branch.id == loggedBranchId) {
    userBranch = branch.branchName;
    break;
  }
}

final filteredCustomers = ledger.customers.where((customer) {
  return customer.soldLocation.toUpperCase() ==
      userBranch.toUpperCase();
}).toList();

final branchCustomers = ledger.customers.where((c) {
  return c.soldLocation.toUpperCase() == userBranch.toUpperCase();
}).toList();

final totalOutstanding = branchCustomers.fold<double>(
  0,
  (sum, c) => sum + c.outstandingBalance,
);

final totalCharged = branchCustomers.fold<double>(
  0,
  (sum, c) => sum + c.totalCharged,
);

final totalPaid = branchCustomers.fold<double>(
  0,
  (sum, c) => sum + c.totalPaid,
);

final pendingCount = branchCustomers.where(
  (c) => c.outstandingBalance > 0,
).length;

final clearedCount = branchCustomers.where(
  (c) => c.outstandingBalance <= 0,
).length;

final branch = ledger.branches.firstWhere(
  (b) => b.id == loggedBranchId,
  orElse: () => BranchLedgerModel(
    id: 0,
    branchName: '',
  ),
);

final branchName = branch.branchName;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child:          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isMobile(context)
                ? Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: getHeight(context, 13)),
                            Text(
                               branchName.isEmpty
                               ? "Customer Ledger"
                               : "Customer Ledger - $branchName",
                              style: AppTextStyles.headingText22,
                            ),
                            SizedBox(height: getHeight(context, 6)),
                            const Text(
                              "Track customer credit balances across branches and warehouse",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: getWidth(context, 12)),

                      SizedBox(
                        width: 120,
                        height:38,
                        child: ElevatedButton.icon(
                          onPressed: (){context.read<LedgerBloc>().add(FetchLedgerEvent());},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffF5C400),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("Refresh"),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branchName.isEmpty
                            ? "Customer Ledger"
                            : "Customer Ledger - $branchName",
                            style: TextStyle(
                              fontSize: getWidth(context, 28),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: getHeight(context, 6)),
                          const Text(
                            "Track customer credit balances across branches and warehouse",
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 120,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: (){context.read<LedgerBloc>().add(FetchLedgerEvent());},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffF5C400),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("Refresh"),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),

            /// Summary Cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: LedgerScreen._summaryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: Colors.red,
                    title: "Total Outstanding",
                    value: "${formatter.format(totalOutstanding)}",
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: LedgerScreen._summaryCard(
                    icon: Icons.currency_rupee,
                    iconColor: Colors.deepPurple,
                    title: "Total Charged",
                    value: "${formatter.format(totalCharged)}",
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: LedgerScreen._summaryCard(
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                    title: "Total Received",
                    value: "${formatter.format(totalPaid)}",
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: LedgerScreen._summaryCard(
                    icon: Icons.access_time,
                    iconColor: Colors.orange,
                    title: "Pending Customers",
                    value: pendingCount.toString(),
                  ),
                ),
                SizedBox(
                  width: screenWidth - 40,
                  child: LedgerScreen._summaryCard(
                    icon: Icons.people_outline,
                    iconColor: Colors.blue,
                    title: "Cleared Customers",
                    value: clearedCount.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// Filter Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                 boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 4), // Horizontal, Vertical
      ),
    ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Search Field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search customer name...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      SizedBox(
                        height: 56,
                        width: 120,
                        child: ElevatedButton(
                          onPressed: searchCustomer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff08152F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Search",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 16),

                  // const Row(
                  //   children: [
                  //     Icon(Icons.filter_alt_outlined),
                  //     SizedBox(width: 8),
                  //     Text(
                  //       "Filters",
                  //       style: TextStyle(fontWeight: FontWeight.w600),
                  //     ),
                  //   ],
                  // ),

                  // const SizedBox(height: 12),

                  // LedgerScreen._dropdown(
                  //   "All Location",
                  //   selectedLocation,
                  //   const [
                  //     DropdownMenuItem(
                  //       value: "all",
                  //       child: Text("All Locations"),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: "branch",
                  //       child: Text("Branch only"),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: "warehouse",
                  //       child: Text("Warehouse only"),
                  //     ),
                  //   ],
                  //   (value) {
                  //     setState(() {
                  //       selectedLocation = value!;
                  //     });
                  //   },
                  // ),

                  // const SizedBox(height: 12),

                  // LedgerScreen._dropdown(
                  //   "All Branches/Warehouse",
                  //   selectedBranch,
                  //   const [
                  //     DropdownMenuItem(
                  //       value: "all",
                  //       child: Text("All Branches/Warehouse"),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: "warehouse",
                  //       child: Text("Warehouse"),
                  //     ),
                  //     DropdownMenuItem(value: "gunjur", child: Text("GUNJUR")),
                  //     DropdownMenuItem(
                  //       value: "krpuram",
                  //       child: Text("KRPURAM"),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: "sarjapuram",
                  //       child: Text("SARJAPURAM"),
                  //     ),
                  //   ],
                  //   (value) {
                  //     setState(() {
                  //       selectedBranch = value!;
                  //     });
                  //   },
                  // ),

                  const SizedBox(height: 12),

                  LedgerScreen._dropdown(
                    "All Status",
                    selectedStatus,
                    const [
                      DropdownMenuItem(value: "all", child: Text("All Status")),
                      DropdownMenuItem(
                        value: "pending",
                        child: Text("Pending Only"),
                      ),
                      DropdownMenuItem(
                        value: "cleared",
                        child: Text("Cleared Only"),
                      ),
                    ],
                    (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF5C400),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Customer Balance Table
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                 boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 4), // Horizontal, Vertical
      ),
    ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: "Customer Balances ",
                            style: AppTextStyles.headingText20,
                          ),
                          TextSpan(
                            text: "(${filteredCustomers.length} customers)",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  // Header Row
                  Expanded(
                    child: filteredCustomers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.people_outline,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "No credit transactions found",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 40,
                                headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFFF3F4F6),
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "Customer Name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Phone",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Location",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Total Charged",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Total Paid",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Balance",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Last Transaction",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: filteredCustomers.map<DataRow>((
                                  customer,
                                ) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          customer.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(customer.customerNumber),
                                      ),

                                      DataCell(
                                        Text(customer.soldLocation),
                                      ),

                                      DataCell(
                                        Text(
                                         inrFormatter.format(customer.totalCharged),
                                          style: const TextStyle(
                                            color: Colors.deepPurpleAccent,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          inrFormatter.format(customer.totalPaid),
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          inrFormatter.format(customer.outstandingBalance),
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                         customer.lastTransactionDate.isNotEmpty
                                        ? DateFormat('d/M/yyyy').format(
                                           DateTime.parse(customer.lastTransactionDate),
                                         )
                                      : '-'
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
   
  );
} 
}
