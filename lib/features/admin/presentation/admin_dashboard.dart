import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/widget/actions_required_card.dart';
import 'package:proteinova_connect/features/admin/widget/dashboardcard.dart';
import 'package:proteinova_connect/features/admin/widget/recent_activity_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void showDashboardBottomSheet({
  required String title,
  required Widget content,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(28),
      ),
    ),

    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),

        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 6,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    title,
                    style: AppTextStyles.headingText22,
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(child: content),
            ],
          ),
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerColor2,
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          children: [
            SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.amber600, // header color
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Text(
                "Menu",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text('Create Purchase Order'),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.local_shipping_outlined),
              title: Text('Dispatch Items'),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.add_shopping_cart_outlined),
              title: Text('New Sales Entry'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.download_outlined),
              title: Text('Export Report'),
              onTap: () {},
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,

        title: Text("Dashboard Overview", style: AppTextStyles.headingText22),

        actions: [
          IconButton(
            onPressed: () {
              // notification action
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black, // change if needed
              size: 20,
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: "Total Revenue",
                      value: "₹3606",
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.blueAccent,
                    onTap: () {
  showDashboardBottomSheet(
    title: "Total Revenue",

    content: ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                "Branch: Chennai",
                style: AppTextStyles.bodyText14dark,
              ),

              const SizedBox(height: 6),

              Text(
                "Revenue: ₹12,500",
                style: AppTextStyles.bodyText14,
              ),

              Text(
                "Date: 09 May 2026",
                style: AppTextStyles.bodyText14,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                "Branch: Coimbatore",
                style: AppTextStyles.bodyText14dark,
              ),

              const SizedBox(height: 6),

              Text(
                "Revenue: ₹18,200",
                style: AppTextStyles.bodyText14,
              ),

              Text(
                "Date: 09 May 2026",
                style: AppTextStyles.bodyText14,
              ),
            ],
          ),
        ),
      ],
    ),
  );
},   
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DashboardCard(
                      title: "Total Stock Value",
                      value: "₹154494",
                      icon: Icons.stacked_bar_chart,
                      iconColor: AppColors.green,
                      onTap: () {
  showDashboardBottomSheet(
    title: "Total Stock Value",

    content: ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                "Branch: Chennai",
                style: AppTextStyles.bodyText14dark,
              ),

              const SizedBox(height: 6),

              Text(
                "Revenue: ₹12,500",
                style: AppTextStyles.bodyText14,
              ),

              Text(
                "Date: 09 May 2026",
                style: AppTextStyles.bodyText14,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                "Branch: Coimbatore",
                style: AppTextStyles.bodyText14dark,
              ),

              const SizedBox(height: 6),

              Text(
                "Revenue: ₹18,200",
                style: AppTextStyles.bodyText14,
              ),

              Text(
                "Date: 09 May 2026",
                style: AppTextStyles.bodyText14,
              ),
            ],
          ),
        ),
      ],
    ),
  );
},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
  child: DashboardCard(
    title: "Incoming Stock",
    value: "1,88,640 Eggs",
    icon: Icons.local_shipping_outlined,
    iconColor: AppColors.deepOrange,

    onTap: () {
      showDashboardBottomSheet(
        title: "Incoming Stock",

        content: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Supplier: Fresh Farm Eggs",
                    style:
                        AppTextStyles.bodyText14dark,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Quantity: 45,000 Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Grade: A Grade",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Arrival Time: 08:30 AM",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Warehouse: Chennai Central",
                    style: AppTextStyles.bodyText14,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Supplier: Golden Poultry",
                    style:
                        AppTextStyles.bodyText14dark,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Quantity: 72,000 Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Grade: Premium White",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Arrival Time: 11:15 AM",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Warehouse: Coimbatore Hub",
                    style: AppTextStyles.bodyText14,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Supplier: Farm Fresh Layers",
                    style:
                        AppTextStyles.bodyText14dark,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Quantity: 71,640 Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Grade: Brown Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Arrival Time: 02:00 PM",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Warehouse: Madurai Storage",
                    style: AppTextStyles.bodyText14,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  ),
),
                  const SizedBox(width: 10),
                 Expanded(
  child: DashboardCard(
    title: "Dispatched Stock",
    value: "1,890 Eggs",
    icon: Icons.send_outlined,
    iconColor: AppColors.green,

    onTap: () {
      showDashboardBottomSheet(
        title: "Dispatched Stock",

        content: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Branch: Chennai Retail Hub",
                    style:
                        AppTextStyles.bodyText14dark,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Dispatched: 650 Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Vehicle No: TN09 AB 4589",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Dispatch Time: 09:15 AM",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Driver: Ramesh Kumar",
                    style: AppTextStyles.bodyText14,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Branch: Coimbatore Market",
                    style:
                        AppTextStyles.bodyText14dark,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Dispatched: 740 Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Vehicle No: TN37 CD 9901",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Dispatch Time: 11:40 AM",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Driver: Suresh Babu",
                    style: AppTextStyles.bodyText14,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Branch: Madurai Wholesale",
                    style:
                        AppTextStyles.bodyText14dark,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Dispatched: 500 Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Vehicle No: TN58 EF 2210",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Dispatch Time: 03:20 PM",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Driver: Arvind Raj",
                    style: AppTextStyles.bodyText14,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  ),
)
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: "Branch Sales Revenue",
                      value: "₹3606",
                      icon: Icons.store_outlined,
                      iconColor: AppColors.deepOrange,
                      onTap: () {
  showDashboardBottomSheet(
    title: "Branch Sales Revenue",

    content: ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                "Branch: Chennai",
                style: AppTextStyles.bodyText14dark,
              ),

              const SizedBox(height: 6),

              Text(
                "Revenue: ₹12,500",
                style: AppTextStyles.bodyText14,
              ),

              Text(
                "Date: 09 May 2026",
                style: AppTextStyles.bodyText14,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                "Branch: Coimbatore",
                style: AppTextStyles.bodyText14dark,
              ),

              const SizedBox(height: 6),

              Text(
                "Revenue: ₹18,200",
                style: AppTextStyles.bodyText14,
              ),

              Text(
                "Date: 09 May 2026",
                style: AppTextStyles.bodyText14,
              ),
            ],
          ),
        ),
      ],
    ),
  );
},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
  child: DashboardCard(
    title: "Total Stock Eggs",
    value: "26,190 Eggs",
    icon: Icons.egg_outlined,
    iconColor: AppColors.blueAccent,

    onTap: () {
      showDashboardBottomSheet(
        title: "Total Stock Eggs",

        content: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Branch: Chennai Central",
                    style:
                        AppTextStyles.bodyText14dark,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Available Stock: 8,540 Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Brown Eggs: 4,200",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "White Eggs: 4,340",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Last Updated: 09 May 2026",
                    style: AppTextStyles.bodyText14,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Branch: Coimbatore Hub",
                    style:
                        AppTextStyles.bodyText14dark,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Available Stock: 9,120 Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Brown Eggs: 5,000",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "White Eggs: 4,120",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Last Updated: 09 May 2026",
                    style: AppTextStyles.bodyText14,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Branch: Madurai Warehouse",
                    style:
                        AppTextStyles.bodyText14dark,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Available Stock: 8,530 Eggs",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Brown Eggs: 3,900",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "White Eggs: 4,630",
                    style: AppTextStyles.bodyText14,
                  ),

                  Text(
                    "Last Updated: 09 May 2026",
                    style: AppTextStyles.bodyText14,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  ),
)
                ],
              ),
              const SizedBox(height: 10),
              DashboardCard(
                title: "Branch Eggs Sold",
                value: "26,190 Eggs",
                icon: Icons.egg_outlined,
                iconColor: AppColors.green,
               onTap: () {
    showDashboardBottomSheet(
      title: "Branch Eggs Sold",

      content: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "Branch: Chennai Central",
                  style:
                      AppTextStyles.bodyText14dark,
                ),

                const SizedBox(height: 6),

                Text(
                  "Eggs Sold: 8,540",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "Revenue: ₹18,500",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "Top Category: Brown Eggs",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "Updated: 09 May 2026",
                  style: AppTextStyles.bodyText14,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "Branch: Coimbatore Hub",
                  style:
                      AppTextStyles.bodyText14dark,
                ),

                const SizedBox(height: 6),

                Text(
                  "Eggs Sold: 9,120",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "Revenue: ₹21,300",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "Top Category: White Eggs",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "Updated: 09 May 2026",
                  style: AppTextStyles.bodyText14,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "Branch: Madurai Warehouse",
                  style:
                      AppTextStyles.bodyText14dark,
                ),

                const SizedBox(height: 6),

                Text(
                  "Eggs Sold: 8,530",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "Revenue: ₹16,900",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "Top Category: Country Eggs",
                  style: AppTextStyles.bodyText14,
                ),

                Text(
                  "Updated: 09 May 2026",
                  style: AppTextStyles.bodyText14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
              ),
              const SizedBox(height: 10),
              RecentActivityCard(),
              const SizedBox(height: 10),
              ActionsRequiredCard(),
            ],
          ),
        ),
      ),
    );
  }
}
