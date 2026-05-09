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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerColor2,

      // drawer: Drawer(
      //   child: ListView(
      //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      //     children: [
      //       SizedBox(height: 25),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      //         margin: const EdgeInsets.only(bottom: 20),
      //         decoration: BoxDecoration(
      //           color: AppColors.amber600, // header color
      //           borderRadius: BorderRadius.circular(12),
      //         ),

      //         child: const Text(
      //           "Menu",
      //           style: TextStyle(
      //             fontSize: 20,
      //             fontWeight: FontWeight.bold,
      //             color: Colors.white,
      //           ),
      //         ),
      //       ),

      //       ListTile(
      //         leading: Icon(Icons.add_circle_outline),
      //         title: Text('Create Purchase Order'),
      //         onTap: () {},
      //       ),

      //       ListTile(
      //         leading: Icon(Icons.local_shipping_outlined),
      //         title: Text('Dispatch Items'),
      //         onTap: () {},
      //       ),

      //       ListTile(
      //         leading: Icon(Icons.add_shopping_cart_outlined),
      //         title: Text('New Sales Entry'),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.download_outlined),
      //         title: Text('Export Report'),
      //         onTap: () {},
      //       ),
      //     ],
      //   ),
      // ),
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DashboardCard(
                      title: "Total Stock Value",
                      value: "₹154494",
                      icon: Icons.stacked_bar_chart,
                      iconColor: AppColors.green,
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DashboardCard(
                      title: "Dispatched Stock ",
                      value: "1,890 Eggs",
                      icon: Icons.send_outlined,
                      iconColor: AppColors.green,
                    ),
                  ),
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DashboardCard(
                      title: "Total Stock Eggs",
                      value: "26,190 Eggs",
                      icon: Icons.egg_outlined,
                      iconColor: AppColors.blueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DashboardCard(
                title: "Branch Eggs Sold",
                value: "26,190 Eggs",
                icon: Icons.egg_outlined,
                iconColor: AppColors.green,
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
