import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/sales_dashboard_shimmer.dart';


import 'package:proteinova_connect/features/branch/sales/presentation/sales_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/sales_dashboard_bloc.dart';
import '../bloc/sales_dashboard_event.dart';
import '../bloc/sales_dashboard_state.dart';

class SalesDashboardPage extends StatefulWidget {
  const SalesDashboardPage({super.key});

  @override
  State<SalesDashboardPage> createState() => _SalesDashboardPageState();
}

class _SalesDashboardPageState extends State<SalesDashboardPage> {
 int branchId = 0;
  String userRole = "Staff";
  int? selectedBranchId;
List<BranchModel> branches = [];
 
 String? selectedBranch = "all";
String? selectedDate; 
  @override
  void initState() {
    super.initState();
    
    context.read<SalesDashboardBloc>().add(FetchSalesDashboard());
  }

   Future<void> loadBranchData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        branchId = prefs.getInt('branch_id') ?? 1;
        final roleStr = prefs.getString('role') ?? 'staff';
        userRole = roleStr.isNotEmpty
            ? '${roleStr[0].toUpperCase()}${roleStr.substring(1)}'
            : 'Staff';
      });
      context.read<SalesDashboardBloc>().add(
  FetchSalesDashboard(),
);
    }
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
 appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  toolbarHeight: 90,
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [

      Text(
        "Sales Dashboard",
        style: AppTextStyles.headingText22.copyWith(
          color: Colors.black,
        ),
      ),

      const SizedBox(height: 8),

      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffF9F1D7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Icon(
              Icons.verified_user_outlined,
              size: 18,
              color: Colors.black87,
            ),

            const SizedBox(width: 6),

            Text(
              "Role: Inventory & Ops Admin",
              style: AppTextStyles.bodyText10dark,
            ),
          ],
        ),
      ),
    ],
  ),
),
      body: BlocBuilder<SalesDashboardBloc, SalesDashboardState>(
        builder: (context, state) {
          if (state is SalesDashboardLoading) {
            return  const SalesDashboardShimmer();
          }

          if (state is SalesDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SalesDashboardBloc>().add(
                            FetchSalesDashboard(),
                          );
                    },
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          if (state is SalesDashboardLoaded) {
            final cards = state.salesData["cards"];

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SalesDashboardBloc>().add(
                      FetchSalesDashboard(),
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                       _buildHeader(context),

                       const SizedBox(height: 20),
                    /// Header
                    const Text(
                      "Sales Overview",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Track your sales performance",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Revenue Card
                    _summaryCard(
                      title: "Total Sales Revenue",
                      value:
                          "₹ ${cards["total_sales"]["value"]}",
                      icon: Icons.currency_rupee,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 14),

                    /// Orders + Eggs
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            title: "Orders",
                            value:
                                cards["total_orders"]["value"].toString(),
                            icon: Icons.shopping_cart,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            title: "Eggs Sold",
                            value:
                                cards["total_sales_eggs"]["value"].toString(),
                            icon: Icons.egg_outlined,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    /// Title
      const Text(
        "Recent Sales",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 16),

                    Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 133, 130, 130).withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      

      /// Filters
      Row(
        children: [

          /// Date Filter
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2035),
                );

                if (picked != null) {
                 setState(() {
      selectedDate = DateFormat('yyyy-MM-dd').format(picked);
    });

    context.read<SalesDashboardBloc>().add(
      FetchSalesDashboard(
        branchId: selectedBranch,
        date: selectedDate,
      ),
    );
                }
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text("Select Date"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// Branch Dropdown
          Expanded(
            child: 
DropdownButtonFormField<int?>(
  value: selectedBranchId,
  items: [
    const DropdownMenuItem<int?>(
      value: null,
      child: Text("All Branches"),
    ),
    ...(state.branches).map((branch) {
      return DropdownMenuItem<int?>(
        value: branch.id,
        child: Text(branch.branchName),
      );
    }),
  ],
  onChanged: (value) {
    setState(() {
      selectedBranchId = value;
    });

    context.read<SalesDashboardBloc>().add(
      FetchSalesDashboard(
        branchId: value?.toString(),
        date: selectedDate,
      ),
    );
  },
) ),
        ],
      ),

      const SizedBox(height: 20),

      /// Table
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(const Color(0xffF4F6F9)),
          columnSpacing: 25,
          horizontalMargin: 12,
          columns: const [
            DataColumn(label: Text("Order")),
            DataColumn(label: Text("Customer")),
            DataColumn(label: Text("Branch")),
            DataColumn(label: Text("Eggs")),
            DataColumn(label: Text("Amount")),
            DataColumn(label: Text("Payment")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Date")),
          ],
          rows: state.recentOrders.map<DataRow>((order) {
            return DataRow(
              cells: [

                DataCell(Text(order["order_id"] ?? "")),

                DataCell(Text(order["customer"] ?? "")),

                DataCell(Text(order["branch"] ?? "")),

                DataCell(Text(order["items_qty"].toString())),

                DataCell(
                  Text(
                    "₹${order["amount"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                DataCell(Text(order["payment_method"])),

                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order["payment_status"],
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                DataCell(
                  Text(
                    order["date"]
                        .toString()
                        .substring(0, 10),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ],
  ),
)
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Buttons
    Column(
  children: [

    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor:Colors.white , // Applies to both icon and text
  ),
        onPressed: () {},
        icon: const Icon(Icons.receipt_long_outlined),
        label: const Text("Customer Ledgers"),
      ),
    ),

    const SizedBox(height: 10),

    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xffFFC107),
    foregroundColor: Colors.black, 
  ),
        onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesEntryPage()),
            ).then((_) => loadBranchData()),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text("New Sales Entry"),
      ),
    ),
  ],
)   ],
    ),
  );
}

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyText14
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(.12),
                child: Icon(
                  icon,
                  color: color,
                ),
              )
            ],
          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: AppTextStyles.headingText20
          ),
        ],
      ),
    );
  }
}