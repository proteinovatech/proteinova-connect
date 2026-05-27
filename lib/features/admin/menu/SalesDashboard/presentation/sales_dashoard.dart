import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/bloc/sales_dashboard_bloc.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/bloc/sales_dashboard_state.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/presentation/sales_entry_page.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/widget/sales_row.dart';

class SalesDashboardPage extends StatefulWidget {
  const SalesDashboardPage({super.key});

  @override
  State<SalesDashboardPage> createState() => _SalesDashboardPageState();
}

class _SalesDashboardPageState extends State<SalesDashboardPage> {
 
  TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;
  String selectedWarehouse = "All Branches";
  String formattedDate = "Select Date";
  List<String> warehouseList = [];
  int currentPage = 1;
  List filteredOrders = [];
  int itemsPerPage = 10;
  List get paginatedOrders {
    final startIndex = (currentPage - 1) * itemsPerPage;

    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= filteredOrders.length) {
      return [];
    }

    return filteredOrders.sublist(
      startIndex,
      endIndex > filteredOrders.length ? filteredOrders.length : endIndex,
    );
  }

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white, // IMPORTANT
        elevation: 0,
        scrolledUnderElevation: 0, // IMPORTANT

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.dark),
        ),

        titleSpacing: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sales Dashboard", style: AppTextStyles.headingText20),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xffFFF7D6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 14,
                    color: Colors.black,
                  ),

                  SizedBox(width: 6),
                  const Text(
                    "Role: Inventory & Ops Admin",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body:  BlocConsumer<SalesDashboardBloc, SalesDashboardState>(
  listener: (context, state) {

    if (state is SalesDashboardError) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
        ),
      );
    }
  },

  builder: (context, state) {

    if (state is SalesDashboardLoading) {

      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is SalesDashboardLoaded) {

      final salesData = state.salesData;

      final recentOrders = state.recentOrders;
      if (filteredOrders.isEmpty) {
  filteredOrders = List.from(recentOrders);
}
      filteredOrders = recentOrders;

      return  SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SalesEntryPage(),
                        ),
                      );
                    },

                    child: Container(
                      height: 35,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: AppColors.amber600,
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline),

                            SizedBox(width: 5),

                            Text(
                              "New Sales Entry",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// DASHBOARD CARDS
                  Row(
                    children: [
                      /// TOTAL SALES
                      /// TOTAL SALES
                      Expanded(
                        child: dashboardCard(
                          title: "Total Sales Revenue",

                          value:
                              "₹ ${salesData['cards']?['total_sales']?['value'] ?? salesData['cards']?['sales_today']?['amount'] ?? 0}",
                          icon: Icons.layers_outlined,

                          iconColor: AppColors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),

                      /// TOTAL ORDERS
                      Expanded(
                        child: dashboardCard(
                          title: "Total Orders",

                          value:
                              "${salesData['cards']?['total_orders']?['value'] ?? salesData['header']?['today_sales']?['count'] ?? recentOrders.length}",

                          icon: Icons.receipt_long_outlined,

                          iconColor: AppColors.green,
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// TOTAL EGGS
                      Expanded(
                        child: dashboardCard(
                          title: "Total Sales Eggs",

                          value:
                              "${salesData['cards']?['total_sales_eggs']?['value'] ?? salesData['total_eggs'] ?? 0}",

                          icon: Icons.egg_outlined,

                          iconColor: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  /// TITLE
                  Text("Recent Sales", style: AppTextStyles.headingText20),

                  const SizedBox(height: 2),

                  Text(
                    "Review and manage your latest branch sales and customer orders",
                    style: AppTextStyles.bodyText12,
                  ),

                  const SizedBox(height: 10),

                  /// SEARCH
                  // TextField(
                  //   controller: searchController,

                  //   onChanged: (value) {
                  //     setState(() {
                  //       currentPage = 1;

                  //       if (value.isEmpty) {
                  //         filteredOrders = recentOrders;
                  //       } else {
                  //         filteredOrders = recentOrders.where((order) {
                  //           return order['customer']
                  //                   .toString()
                  //                   .toLowerCase()
                  //                   .contains(value.toLowerCase()) ||
                  //               order['order_id']
                  //                   .toString()
                  //                   .toLowerCase()
                  //                   .contains(value.toLowerCase());
                  //         }).toList();
                  //       }
                  //     });
                  //   },

                  //   decoration: InputDecoration(
                  //     hintText: "Search orders, customers...",
                  //     prefixIcon: const Icon(Icons.search),

                  //     filled: true,
                  //     fillColor: Colors.white,

                  //     contentPadding: const EdgeInsets.symmetric(vertical: 8),

                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(14),
                  //       borderSide: BorderSide(color: Colors.grey.shade300),
                  //     ),

                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(14),
                  //       borderSide: BorderSide(color: Colors.grey.shade300),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 10),

                  /// FILTERS
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;

                                formattedDate =
                                    "${pickedDate.day.toString().padLeft(2, '0')} / "
                                    "${pickedDate.month.toString().padLeft(2, '0')} / "
                                    "${pickedDate.year}";

                                filteredOrders = recentOrders.where((order) {
                                  final orderDate = DateTime.tryParse(
                                    order['date'].toString(),
                                  );

                                  if (orderDate == null) {
                                    return false;
                                  }

                                  return orderDate.year == pickedDate.year &&
                                      orderDate.month == pickedDate.month &&
                                      orderDate.day == pickedDate.day;
                                }).toList();

                                currentPage = 1;
                              });
                            }
                          },

                          child: filterBox(
                            icon: Icons.calendar_today_outlined,
                            text: formattedDate,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Container(
                          height: 40,

                          padding: const EdgeInsets.symmetric(horizontal: 12),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(12),

                            border: Border.all(color: Colors.grey.shade300),
                          ),

                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedWarehouse,

                              isExpanded: true,

                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                              ),

                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),

                              dropdownColor: Colors.white,

                              items: warehouseList.map((String warehouse) {
                                return DropdownMenuItem<String>(
                                  value: warehouse,

                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.home_work_outlined,
                                        size: 15,
                                        color: Colors.grey,
                                      ),

                                      const SizedBox(width: 8),

                                      Flexible(
                                        child: Text(
                                          warehouse,

                                          overflow: TextOverflow.ellipsis,

                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              onChanged: (String? value) {
                                setState(() {
                                  selectedWarehouse = value!;
                                });

                                print("SELECTED BRANCH => $selectedWarehouse");
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      GestureDetector(
                        onTap: () async {
                         
                          searchController.clear();

                          formattedDate = "Select Date";

                          selectedDate = null;

                          currentPage = 1;

                          
                        },

                        child: Container(
                          height: 40,
                          width: 40,

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(14),

                            border: Border.all(color: Colors.grey.shade300),
                          ),

                          child: const Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// TABLE HEADER
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isMobile = constraints.maxWidth < 600;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: Container(
                          /// RESPONSIVE WIDTH
                          width: isMobile ? 700 : constraints.maxWidth,

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(14),

                            border: Border.all(color: Colors.grey.shade200),
                          ),

                          child: Column(
                            children: [
                              /// HEADER
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 10,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,

                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),

                                    topRight: Radius.circular(14),
                                  ),
                                ),

                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 32,

                                      child: Text(
                                        "ORDER DETAILS",

                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,

                                          fontSize: 10,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 20,

                                      child: Center(
                                        child: Text(
                                          "CUSTOMER",

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,

                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 20,

                                      child: Center(
                                        child: Text(
                                          "BRANCH",

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,

                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 18,

                                      child: Center(
                                        child: Text(
                                          "ITEMS",

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,

                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 18,

                                      child: Center(
                                        child: Text(
                                          "AMOUNT",

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,

                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 18,

                                      child: Center(
                                        child: Text(
                                          "STATUS",

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,

                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 14,

                                      child: Center(
                                        child: Text(
                                          "ACTION",

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,

                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// DATA
                              ...List.generate(paginatedOrders.length, (index) {
                                final order = paginatedOrders[index];

                                return SalesRow(
                                  order:
                                      order['order_id']?.toString() ??
                                      order['id']?.toString() ??
                                      "-",

                                  date:
                                      order['date']?.toString() ??
                                      order['created_at']?.toString() ??
                                      "-",

                                  customer:
                                      order['customer']?.toString() ??
                                      order['customer_name']?.toString() ??
                                      "-",

                                  branch:
                                      order['branch']?.toString() ??
                                      order['sales_happen']?.toString() ??
                                      "Main Branch",

                                  items:
                                      "${order['items_qty'] ?? order['total_items'] ?? 0} Units",

                                  amount:
                                      "₹ ${order['amount'] ?? order['total_amount'] ?? 0}",

                                  status:
                                      order['payment_status']?.toString() ??
                                      order['payment_method']?.toString() ??
                                      "Pending",

                                  paid:
                                      (order['payment_status']
                                              ?.toString()
                                              .toLowerCase() ==
                                          "paid") ||
                                      (order['payment_method']
                                              ?.toString()
                                              .toLowerCase() ==
                                          "cash"),
                                );
                              }),

                              if (paginatedOrders.isEmpty)
                                Container(
                                  height: 120,

                                  alignment: Alignment.center,

                                  child: const Text(
                                    "No recent orders found",

                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  /// PAGINATION
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        /// TEXT
                        Text(
                          filteredOrders.isEmpty
                              ? "Showing 0 records"
                              : "Showing ${((currentPage - 1) * itemsPerPage) + 1} to "
                                    "${(((currentPage - 1) * itemsPerPage) + paginatedOrders.length)} "
                                    "of ${filteredOrders.length} records",

                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),

                        /// BUTTONS
                        Row(
                          children: [
                            /// PREVIOUS
                            GestureDetector(
                              onTap: () {
                                if (currentPage > 1) {
                                  setState(() {
                                    currentPage--;
                                  });
                                }
                              },

                              child: Container(
                                height: 38,
                                width: 38,

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),

                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),

                                child: Icon(
                                  Icons.chevron_left,
                                  color: currentPage > 1
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            /// CURRENT PAGE
                            Container(
                              height: 38,
                              width: 38,

                              decoration: BoxDecoration(
                                color: AppColors.amber600,
                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Center(
                                child: Text(
                                  "$currentPage",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            /// NEXT
                            GestureDetector(
                              onTap: () {
                                if ((currentPage * itemsPerPage) <
                                    filteredOrders.length) {
                                  setState(() {
                                    currentPage++;
                                  });
                                }
                              },

                              child: Container(
                                height: 38,
                                width: 38,

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),

                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),

                                child: Icon(
                                  Icons.chevron_right,
                                  color:
                                      (currentPage * itemsPerPage) <
                                          filteredOrders.length
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
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
    );
  }

  /// DASHBOARD CARD
  static Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(.04),
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Icon(icon, color: iconColor),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// FILTER BOX
  static Widget filterBox({required IconData icon, required String text}) {
    return Container(
      height: 40,

      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        children: [
          Icon(icon, size: 14),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12, // text size
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
