import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/services/credit_ledger_service.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

class CreditLedgerScreen extends StatefulWidget {
  const CreditLedgerScreen({super.key});
  @override
  State<CreditLedgerScreen> createState() => _CreditLedgerScreenState();

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

class _CreditLedgerScreenState extends State<CreditLedgerScreen> {
  final CreditLedgerService _service = CreditLedgerService();

  bool isLoading = true;
  String error = '';

  double totalOutstanding = 0;
  double totalCharged = 0;
  double totalReceived = 0;
  int pendingCustomers = 0;
  int clearedCustomers = 0;

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
    fetchCreditLedger();
  }

  Future<void> fetchCreditLedger() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final data = await _service.getCreditLedger();

      final summary = data['summary'] ?? {};

      setState(() {
        totalOutstanding =
            double.tryParse(summary['total_outstanding'].toString()) ?? 0.0;

        totalCharged =
            double.tryParse(summary['total_charged'].toString()) ?? 0.0;

        totalReceived =
            double.tryParse(summary['total_paid'].toString()) ?? 0.0;

        pendingCustomers = summary['pending_count'] ?? 0;

        clearedCustomers = summary['cleared_count'] ?? 0;

        customers = List<Map<String, dynamic>>.from(data['customers'] ?? []);
        filteredCustomers = List<Map<String, dynamic>>.from(customers);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });

      print("API Error: $e");
    }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 56) / 2;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                            Row(
                              children: [
                                 IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () {
                                  Navigator.pop(context);
                                  },
                                  ),
                                Text(
                                  "Credit Ledger",
                                  style: AppTextStyles.headingText25,
                                ),
                              ],
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
                        width: 130,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: fetchCreditLedger,
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
                          Row(
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () {
                                  Navigator.pop(context);
                                  },
                                  ),
                              Text(
                                "Credit Ledger",
                                style: TextStyle(
                                  fontSize: getWidth(context, 28),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: getHeight(context, 6)),
                          const Text(
                            "Track customer credit balances across branches and warehouse",
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 130,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: fetchCreditLedger,
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
                  child: CreditLedgerScreen._summaryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: Colors.red,
                    title: "Total Outstanding",
                    value: "${formatter.format(totalOutstanding)}",
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: CreditLedgerScreen._summaryCard(
                    icon: Icons.currency_rupee,
                    iconColor: Colors.deepPurple,
                    title: "Total Charged",
                    value: "${formatter.format(totalCharged)}",
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: CreditLedgerScreen._summaryCard(
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                    title: "Total Received",
                    value: "${formatter.format(totalReceived)}",
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: CreditLedgerScreen._summaryCard(
                    icon: Icons.access_time,
                    iconColor: Colors.orange,
                    title: "Pending Customers",
                    value: pendingCustomers.toString(),
                  ),
                ),
                SizedBox(
                  width: screenWidth - 40,
                  child: CreditLedgerScreen._summaryCard(
                    icon: Icons.people_outline,
                    iconColor: Colors.blue,
                    title: "Cleared Customers",
                    value: clearedCustomers.toString(),
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
                  const SizedBox(height: 16),

                  const Row(
                    children: [
                      Icon(Icons.filter_alt_outlined),
                      SizedBox(width: 8),
                      Text(
                        "Filters",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  CreditLedgerScreen._dropdown(
                    "All Location",
                    selectedLocation,
                    const [
                      DropdownMenuItem(
                        value: "all",
                        child: Text("All Locations"),
                      ),
                      DropdownMenuItem(
                        value: "branch",
                        child: Text("Branch only"),
                      ),
                      DropdownMenuItem(
                        value: "warehouse",
                        child: Text("Warehouse only"),
                      ),
                    ],
                    (value) {
                      setState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  CreditLedgerScreen._dropdown(
                    "All Branches/Warehouse",
                    selectedBranch,
                    const [
                      DropdownMenuItem(
                        value: "all",
                        child: Text("All Branches/Warehouse"),
                      ),
                      DropdownMenuItem(
                        value: "warehouse",
                        child: Text("Warehouse"),
                      ),
                      DropdownMenuItem(value: "gunjur", child: Text("GUNJUR")),
                      DropdownMenuItem(
                        value: "krpuram",
                        child: Text("KRPURAM"),
                      ),
                      DropdownMenuItem(
                        value: "sarjapuram",
                        child: Text("SARJAPURAM"),
                      ),
                    ],
                    (value) {
                      setState(() {
                        selectedBranch = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  CreditLedgerScreen._dropdown(
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
                            text: "(${customers.length} customers)",
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
                                          customer['customer_name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(customer['customer_number'] ?? ''),
                                      ),

                                      DataCell(
                                        Text(customer['sold_location'] ?? ''),
                                      ),

                                      DataCell(
                                        Text(
                                          inrFormatter.format(
                                            double.tryParse(
                                                  customer['total_charged']
                                                          ?.toString() ??
                                                      '0',
                                                ) ??
                                                0,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.deepPurpleAccent,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          inrFormatter.format(
                                            double.tryParse(
                                                  customer['total_paid']
                                                          ?.toString() ??
                                                      '0',
                                                ) ??
                                                0,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          inrFormatter.format(
                                            double.tryParse(
                                                  customer['outstanding_balance']
                                                          ?.toString() ??
                                                      '0',
                                                ) ??
                                                0,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          customer['last_transaction_date'] !=
                                                  null
                                              ? DateFormat('d/M/yyyy').format(
                                                  DateTime.parse(
                                                    customer['last_transaction_date'],
                                                  ),
                                                )
                                              : '-',
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
      ),
    );
  }
}
