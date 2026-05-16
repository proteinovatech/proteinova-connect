import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_bloc.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_event.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_state.dart';
import 'package:proteinova_connect/features/branch/sales/presentation/sales_entry.dart';
import 'package:proteinova_connect/features/branch/sales/widget/dashboardcard.dart';
import 'package:proteinova_connect/features/branch/sales/widget/dashboardcard2.dart';
import 'package:proteinova_connect/features/branch/sales/widget/sales_skeleton_loader.dart';

import '../data/repository/sales_repository.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});
  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  Size get size => MediaQuery.of(context).size;
  int branchId = 0;
  @override
  void initState() {
    super.initState();

    loadBranchData();
  }

  Future<void> loadBranchData() async {
    /// TEMP STATIC ID
    /// replace later with login user branch id

    branchId = 1;

    if (mounted) {
      setState(() {});
    }
  }

  Color getStatusColor(String status, {String? orderId}) {
    final s = status.toLowerCase();
    final id = (orderId ?? "").toUpperCase();

    // Pending: Orange
    if (s == "pending_review" ||
        s == "pending approval" ||
        id.startsWith("REQ-")) {
      return Colors.orange;
    }

    // Approved/Accepted: Green
    if (s == "approved" ||
        s == "completed" ||
        s == "paid" ||
        s == "success" ||
        s == "accepted") {
      return Colors.green;
    }

    // Rejected/Cancelled: Red
    if (s == "rejected" || s == "cancelled") {
      return Colors.red;
    }

    // Transit/Loading: Blue/Light Blue
    if (s == "delivered" || s == "in transit") {
      return Colors.blue;
    }
    
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SalesBloc()..add(FetchSalesDashboard(branchId: branchId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<SalesBloc, SalesState>(
          builder: (context, state) {
            if (state is SalesLoading) {
              return const Center(child: SalesSkeletonLoader());
            }

            if (state is SalesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${state.error}"),
                    ElevatedButton(
                      onPressed: () {
                        (context) =>
                            SalesBloc()
                              ..add(FetchSalesDashboard(branchId: branchId));
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            if (state is SalesDashboardLoaded) {
              final dashboardData = state.dashboardData;
              final salesOrders = state.salesOrders;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context, 15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getHeight(context, 15)),
                    _buildHeader(),
                    const Divider(),
                    Text(
                      "Sales & Dispatch",
                      style: AppTextStyles.headingText22,
                    ),
                    SizedBox(height: getHeight(context, 10)),
                    _buildNewSaleButton(),
                    SizedBox(height: getHeight(context, 10)),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.blueAccent,

                        onRefresh: () async {
                          context.read<SalesBloc>().add(
                            FetchSalesDashboard(branchId: branchId),
                          );
                        },

                        child: ListView(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          children: [
                            _buildDashboardCards(dashboardData),
                            SizedBox(height: getHeight(context, 25)),
                            _buildRecentSalesTable(salesOrders),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          "assets/erplogo.png",
          height: getHeight(context, 40),
          width: getWidth(context, 130),
        ),
        // Row(
        //   children: [
        //     const Icon(Icons.search_outlined),
        //     SizedBox(width: size.width * 0.02),
        //     const Icon(Icons.notifications_outlined),
        //     SizedBox(width: size.width * 0.02),
        //     CircleAvatar(
        //       radius: 18,
        //       backgroundColor: Colors.grey.shade300,
        //       child: Icon(
        //         Icons.person,
        //         size: 20,
        //         color: AppColors.background,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildNewSaleButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SalesEntryPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.amber600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.dark),
            SizedBox(width: getWidth(context, 8)),
            Text("New Sale", style: AppTextStyles.headingText20),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCards(Map<String, dynamic> data) {
    final cards = data["cards"] ?? {};
    final totalSales = cards["total_sales"] ?? {};
    final totalOrders = cards["total_orders"] ?? {};
    final totalEggs = cards["total_sales_eggs"] ?? {};

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: "Total Sales",
                value: "₹${totalSales["value"] ?? "0"}",
                percent: "LIFETIME",
                subtitle: "Revenue total",
                icon: Icons.currency_rupee,
                iconBg: const Color(0xfffffbeb),
                iconColor: const Color(0xffd97706),
              ),
            ),
            SizedBox(width: getWidth(context, 10)),
            Expanded(
              child: DashboardCard2(
                title: "Total Orders",
                value: totalOrders["value"]?.toString() ?? "0",
                subtitle: "Transactions lifetime",
                icon: Icons.shopping_bag_outlined,
                iconBg: const Color(0xfff1f6ff),
                iconColor: const Color(0xff2563eb),
              ),
            ),
          ],
        ),
        SizedBox(height: getHeight(context, 10)),
        Row(
          children: [
            Expanded(
              child: DashboardCard2(
                title: "Eggs Sold (Today)",
                value: totalEggs["value"]?.toString() ?? "0",
                subtitle: "Today's volume",
                icon: Icons.egg_outlined,
                iconBg: const Color(0xffeff6ff),
                iconColor: const Color(0xff3b82f6),
              ),
            ),
            SizedBox(width: getWidth(context, 10)),
            Expanded(
              child: DashboardCard(
                title: "Today's Sales",
                value: "₹${totalSales["today"] ?? "0"}",
                percent: "TODAY",
                subtitle: "Transactions recorded",
                icon: Icons.trending_up,
                iconBg: const Color(0xfff0fdf4),
                iconColor: const Color(0xff16a34a),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentSalesTable(List<dynamic> orders) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Sales Orders",
                style: AppTextStyles.headingText20,
              ),
              // _buildExportButton(),
            ],
          ),
          SizedBox(height: getHeight(context, 20)),
          _buildTableHeader(),
          SizedBox(height: getHeight(context, 10)),
          orders.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No Sales Orders Found",
                      style: AppTextStyles.bodyText14,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: orders.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey.shade300),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderRow(order);
                  },
                ),
        ],
      ),
    );
  }

  // Widget _buildExportButton() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: AppColors.border2),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Icons.open_in_new, color: AppColors.blueAccent, size: 18),
  //         SizedBox(width: 5),
  //         Text("Export", style: AppTextStyles.blueText2),
  //       ],
  //     ),
  //   );
  // }
  // Widget _buildExportButton() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  //     decoration: BoxDecoration(
  //       border: Border.all(color:AppColors.border2),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child:  Row(
  //       children: [
  //         Icon(Icons.open_in_new, color:AppColors.blueAccent, size: 18),
  //         SizedBox(width: 5),
  //         Text(
  //           "Export",
  //           style:AppTextStyles.blueText2
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: Text("ORDER ID", style: AppTextStyles.bodyText12dark),
          ),
          Expanded(
            flex: 1,
            child: Text("DATE", style: AppTextStyles.bodyText12dark),
          ),
          Expanded(
            flex: 2,
            child: Text("CUSTOMER", style: AppTextStyles.bodyText12dark),
          ),
          Expanded(
            flex: 1,
            child: Text("QTY", style: AppTextStyles.bodyText12dark),
          ),
          Expanded(
            flex: 2,
            child: Text("AMOUNT", style: AppTextStyles.bodyText12dark),
          ),
          Expanded(
            flex: 2,
            child: Text("STATUS", style: AppTextStyles.bodyText12dark),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(dynamic orderId) async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final order = await _repository.fetchSingleSale(orderId.toString());
      if (mounted) {
        Navigator.pop(context); // Remove loader
        _showOrderModal(order);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _showOrderModal(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Order Details: ${order['invoice_no'] ?? 'N/A'}"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Customer: ${order['customer_name'] ?? 'Walk-in'}"),
              Text("Date: ${order['created_at']}"),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: (order['items'] as List? ?? []).length,
                  itemBuilder: (context, index) {
                    final item = order['items'][index];
                    return ListTile(
                      title: Text(item['egg_category_grade'] ?? ""),
                      subtitle: Text(
                        "${item['trays']} Trays | ${item['total_eggs']} Eggs",
                      ),
                      trailing: Text("₹${item['subtotal']}"),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${order['total_amount']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  final SalesRepository _repository = SalesRepository();

  Widget _buildOrderRow(dynamic order) {
    final String orderId = (order["order_id"] ?? order["id"] ?? "-").toString();
    final String rawStatus =
        (order["order_status"] ?? order["status"] ?? "").toString();

    // Determine Display Status
    String displayStatus = rawStatus;
    if (displayStatus.isEmpty || displayStatus == "-") {
      if (orderId.toUpperCase().startsWith("REQ-")) {
        displayStatus = "Pending Approval";
      } else {
        displayStatus = "Approved"; // Fallback for normal SO- orders
      }
    } else if (displayStatus.toUpperCase() == "PENDING_REVIEW") {
      displayStatus = "Pending Approval";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: InkWell(
        onTap: () => _showOrderDetails(order["id"] ?? order["order_id"]),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(orderId, style: AppTextStyles.bodyText12),
            ),
            Expanded(
              flex: 2,
              child: Text(
                order["date"]?.toString().split('T').first ?? "-",
                style: AppTextStyles.bodyText12,
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order["customer"]?.toString() ?? "-",
                    style: AppTextStyles.bodyText12,
                  ),
                  Text(
                    order["payment_method"]?.toString() ?? "CASH",
                    style: AppTextStyles.bodyText12,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "${order["items_qty"] ?? 0} Eggs",
                style: AppTextStyles.bodyText12,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "₹${order["amount"]}",
                style: AppTextStyles.bodyText12,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(displayStatus, orderId: orderId),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  displayStatus,
                  style: AppTextStyles.whiteText.copyWith(
                    fontSize: 9, // Slightly smaller to prevent wrapping
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
