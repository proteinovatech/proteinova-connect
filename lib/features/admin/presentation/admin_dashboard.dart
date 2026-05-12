import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/data/model/dashboard_model.dart';
import 'package:proteinova_connect/features/admin/data/services/dashboard_service.dart';
import 'package:proteinova_connect/features/admin/widget/actions_required_card.dart';
import 'package:proteinova_connect/features/admin/widget/dashboardcard.dart';
import 'package:proteinova_connect/features/admin/widget/recent_activity_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  DashboardModel? dashboard;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final data = await DashboardService().fetchDashboard();

      setState(() {
        dashboard = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e);
    }
  }

  void showDashboardBottomSheet({
    required String title,
    required Widget content,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(title, style: AppTextStyles.headingText22),

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
      backgroundColor: AppColors.white,
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
              size: 30,
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                            value: "₹${dashboard?.revenue ?? 0}",
                            icon: Icons.payments_outlined,
                            iconColor: AppColors.blueAccent,
                            onTap: () {
                              showDashboardBottomSheet(
                                title: "Total Revenue",

                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),

                                        color: AppColors.background1,
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "Current Revenue",
                                            style: AppTextStyles.bodyText14dark,
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            "₹${dashboard?.revenue ?? 0}",
                                            style: AppTextStyles.bodyText16,
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
                            value: "${dashboard?.totalStockValue ?? 0}",
                            icon: Icons.stacked_bar_chart,
                            iconColor: AppColors.green,
                            onTap: () {
                              showDashboardBottomSheet(
                                title: "Total Stock Value",

                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),

                                        color: AppColors.background1,
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "Total Stock Value",
                                            style: AppTextStyles.bodyText14dark,
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            "₹${dashboard?.totalStockValue ?? 0}",
                                            style: AppTextStyles.bodyText16,
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
                            value: "${dashboard?.incomingStockEggs ?? 0}",
                            icon: Icons.local_shipping_outlined,
                            iconColor: AppColors.deepOrange,

                            onTap: () {
                              showDashboardBottomSheet(
                                title: "Incoming Stock",

                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),

                                        color: AppColors.background1,
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "Incoming Stock",
                                            style: AppTextStyles.bodyText14dark,
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            "₹${dashboard?.incomingStockEggs ?? 0}",
                                            style: AppTextStyles.bodyText16,
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
                            value:
                                "${dashboard?.dispatchedStockEggs ?? 0} Eggs",
                            icon: Icons.send_outlined,
                            iconColor: AppColors.green,

                            onTap: () {
                              showDashboardBottomSheet(
                                title: "Dispatched Stock",

                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),

                                        color: AppColors.background1,
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "Dispatched Stocks",
                                            style: AppTextStyles.bodyText14dark,
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            "${dashboard?.dispatchedStockEggs ?? 0} Eggs",
                                            style: AppTextStyles.bodyText16,
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
                            title: "Branch Sales Revenue",
                            value: "₹${dashboard?.revenue ?? 0}",
                            icon: Icons.store_outlined,
                            iconColor: AppColors.deepOrange,
                            onTap: () {
                              showDashboardBottomSheet(
                                title: "Branch Sales Revenue",

                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),

                                        color: AppColors.background1,
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "Branch Sales Revenue",
                                            style: AppTextStyles.bodyText14dark,
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            "₹${dashboard?.revenue ?? 0}",
                                            style: AppTextStyles.bodyText16,
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
                            value: "${dashboard?.totalStockEggs ?? 0} Eggs",
                            icon: Icons.egg_outlined,
                            iconColor: AppColors.blueAccent,

                            onTap: () {
                              showDashboardBottomSheet(
                                title: "Total Stock Eggs",

                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),

                                        color: AppColors.background1,
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "Total Stock Eggs",
                                            style: AppTextStyles.bodyText14dark,
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            "${dashboard?.totalStockEggs ?? 0} Eggs",
                                            style: AppTextStyles.bodyText16,
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
                    DashboardCard(
                      title: "Branch Eggs Sold",
                      value: "${dashboard?.totalStockEggs ?? 0} Eggs",
                      icon: Icons.egg_outlined,
                      iconColor: AppColors.green,
                      onTap: () {
                        showDashboardBottomSheet(
                          title: "Branch Eggs Sold",

                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),

                                  color: AppColors.background1,
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      "Branch Eggs Sold",
                                      style: AppTextStyles.bodyText14dark,
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "${dashboard?.totalStockEggs ?? 0} Eggs",
                                      style: AppTextStyles.bodyText16,
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
                    RecentActivityCard(
                      activities: dashboard?.recentActivity ?? [],
                    ),
                    const SizedBox(height: 10),
                    ActionsRequiredCard(),
                  ],
                ),
              ),
            ),
    );
  }
}
