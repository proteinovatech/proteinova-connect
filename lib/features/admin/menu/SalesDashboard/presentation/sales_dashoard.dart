import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/presentation/sales_entry_page.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/widget/sales_row.dart';

class SalesDashboardPage extends StatelessWidget {
  const SalesDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F7),
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),

        titleSpacing: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sales Dashboard",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

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

      body: SingleChildScrollView(
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
                height: 38,
                width: double.infinity,

                decoration: BoxDecoration(
                  color: const Color(0xffFFD600),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline),

                      SizedBox(width: 10),

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
                Expanded(
                  child: dashboardCard(
                    title: "Total Sales Revenue",
                    value: "₹ 20,994",
                    icon: Icons.layers_outlined,
                    iconColor: Colors.blue,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: dashboardCard(
                    title: "Total Orders",
                    value: "9",
                    icon: Icons.receipt_long_outlined,
                    iconColor: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: dashboardCard(
                    title: "Total Sales Eggs",
                    value: "840",
                    icon: Icons.egg_outlined,
                    iconColor: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// TITLE
            const Text(
              "Recent Sales",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 2),

            Text(
              "Review and manage your latest branch sales and customer orders",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),

            const SizedBox(height: 10),

            /// SEARCH
            TextField(
              decoration: InputDecoration(
                hintText: "Search orders, customers...",
                prefixIcon: const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(vertical: 8),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// FILTERS
            Row(
              children: [
                Expanded(
                  child: filterBox(
                    icon: Icons.calendar_today_outlined,
                    text: "dd mm yyyy",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: filterBox(
                    icon: Icons.home_work_outlined,
                    text: "All Branches",
                  ),
                ),

                const SizedBox(width: 12),

                Container(
                  height: 40,
                  width: 40,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  child: const Icon(Icons.refresh),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// TABLE HEADER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Row(
                children: [
                  Expanded(
                    flex: 32,
                    child: Text(
                      "ORDER DETAILS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
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
                          fontSize: 11,
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
                          fontSize: 11,
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
                          fontSize: 11,
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
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// SALES ROWS
            salesRow(
              order: "SO-40",
              date: "08 May 2025 • 08:22 am",
              customer: "Rajan",
              items: "4 Units",
              amount: "₹ 0",
              status: "Paid",
              paid: true,
            ),

            salesRow(
              order: "SO-39",
              date: "08 May 2025\n 08:21 am",
              customer: "Rajan",
              items: "2 Units",
              amount: "₹ 0",
              status: "Paid",
              paid: true,
            ),

            salesRow(
              order: "REQ-1",
              date: "08 May 2025\n 07:50 am",
              customer: "Jino",
              items: "4 Units",
              amount: "₹ 0",
              status: "Rejected",
              paid: false,
            ),
            salesRow(
              order: "SO-39",
              date: "08 May 2025\n 08:21 am",
              customer: "Rajan",
              items: "2 Units",
              amount: "₹ 0",
              status: "Paid",
              paid: true,
            ),

            salesRow(
              order: "REQ-1",
              date: "08 May 2025\n 07:50 am",
              customer: "Jino",
              items: "4 Units",
              amount: "₹ 0",
              status: "Rejected",
              paid: false,
            ),

            /// PAGINATION
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  /// TEXT
                  const Text(
                    "Showing 1 to 10 of 10 records",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),

                  /// BUTTONS
                  Row(
                    children: [
                      /// PREVIOUS
                      Container(
                        height: 38,
                        width: 38,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),

                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.grey.shade400,
                        ),
                      ),

                      const SizedBox(width: 8),

                      /// CURRENT PAGE
                      Container(
                        height: 38,
                        width: 38,

                        decoration: BoxDecoration(
                          color: const Color(0xff14213D),
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: const Center(
                          child: Text(
                            "1",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      /// NEXT
                      Container(
                        height: 38,
                        width: 38,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),

                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  /// SALES ROW
}
