import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_bloc.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_event.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_state.dart';
import 'package:proteinova_connect/features/branch/sales/presentation/sales_entry.dart';
import 'package:proteinova_connect/features/branch/sales/widget/dashboardcard.dart';
import 'package:proteinova_connect/features/branch/sales/widget/dashboardcard2.dart';
import 'package:proteinova_connect/features/branch/sales/widget/recent_sales_card.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});
  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  Size get size => MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesBloc()..add(FetchSalesDashboard()),
      child: Scaffold(
        backgroundColor: AppColors.background1,
        body: BlocBuilder<SalesBloc, SalesState>(
          builder: (context, state) {
            if (state is SalesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SalesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${state.error}"),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SalesBloc>().add(FetchSalesDashboard());
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
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.07),
                    _buildHeader(),
                    const Divider(),
                    Text(
                      "Sales & Dispatch",
                      style: AppTextStyles.headingText22,
                    ),
                    const SizedBox(height: 20),
                    _buildNewSaleButton(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        children: [
                          _buildDashboardCards(dashboardData),
                          const SizedBox(height: 25),
                          _buildRecentSalesTable(salesOrders),
                        ],
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
        Image.asset("assets/erplogo.png", height: 40, width: 130),
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
            const SizedBox(width: 8),
            Text("New Sale", style: AppTextStyles.headingText20),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCards(Map<String, dynamic> data) {
    final cards = data["cards"] ?? {};
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: "Sales today",
                value: cards["sales_today"]?["amount"]?.toString() ?? "0",
                percent:
                    cards["sales_today"]?["vs_yesterday_pct"]?.toString() ??
                    "0%",
                subtitle: "Vs yesterday",
                icon: Icons.currency_pound,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardCard2(
                title: "Pending Dispatches",
                value: cards["pending_unloading"]?.toString() ?? "0",
                subtitle: "Requires Assignment",
                icon: Icons.timer_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DashboardCard2(
                title: "Vehicle in transit",
                value: cards["vehicles_in_transit"]?.toString() ?? "0",
                subtitle: "Currently on route",
                icon: Icons.local_shipping,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardCard(
                title: "Completed",
                value:
                    cards["completed_deliveries"]?["today"]?.toString() ?? "0",
                percent: "+5%",
                subtitle: "From Daily Target",
                icon: Icons.check_circle_outline,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.blue,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Sales Orders",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildExportButton(),
            ],
          ),
          const SizedBox(height: 20),
          _buildTableHeader(),
          const SizedBox(height: 10),
          orders.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No Sales Orders Found"),
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

  Widget _buildExportButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.open_in_new, color: Colors.blue, size: 18),
          SizedBox(width: 5),
          Text(
            "Export",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

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
            child: Text(
              "ORDER ID",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "DATE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "CUSTOMER",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "QTY",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "AMOUNT",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "STATUS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(dynamic order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              order["order_id"]?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              order["date"]?.toString().split('T').first ?? "-",
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order["customer"]?.toString() ?? "-",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  order["payment_method"]?.toString() ?? "CASH",
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${order["items_qty"] ?? 0} Tr",
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "₹${order["amount"]}",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color:
                    (order["payment_status"]?.toString().toLowerCase() ==
                        "paid")
                    ? Colors.green
                    : Colors.orange,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                order["payment_status"]?.toString() ?? "-",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
