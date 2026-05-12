import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/repository/dashboard_repository.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/activityitem.dart';

class Resentactivity extends StatefulWidget {
  const Resentactivity({super.key});

  @override
  State<Resentactivity> createState() =>
      _ResentactivityState();
}

class _ResentactivityState
    extends State<Resentactivity> {

  DashboardModel? dashboardModel;
  bool isLoading = true;
  late final DashboardRepository repository;

  @override
  void initState() {
    super.initState();
    repository = DashboardRepository(DioClient().dio);
    fetchRecentActivity();
  }

  Future<void> fetchRecentActivity() async {
    try {
      final result = await repository.fetchDashboardData();

      setState(() {
        dashboardModel = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          AppColors.background1,

      appBar: AppBar(

        backgroundColor:
            AppColors.background,

        scrolledUnderElevation: 0,

        title: const Text(
          "Recent Activity",
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : dashboardModel!.recentActivity.isEmpty

              ? const Center(
                  child: Text(
                    "No Recent Activity",
                  ),
                )

              : Padding(

                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  child: ListView.builder(
                    itemCount: dashboardModel!.recentActivity.length,

                    itemBuilder: (context, index) {
                      final activity = dashboardModel!.recentActivity[index];

                      return Column(

                        children: [

                          ActivityItem(

                            leading:
                                CircleAvatar(

                              radius: 25,

                              backgroundColor:
                                  Colors.grey,

                              child: Icon(

                                getIcon(
                                  activity.tag,
                                ),

                                color:
                                    Colors.white,
                              ),
                            ),

                            title: activity.title,

                            subtitle: Text(
                              activity.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),

                            time: activity.time,

                            tag: activity.tag,
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          const Divider(),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  IconData getIcon(String tag) {

    switch (tag.toLowerCase()) {

      case "delivery":
        return Icons.local_shipping;

      case "error":
        return Icons.error_outline;

      case "procurement":
        return Icons.shopping_cart;

      default:
        return Icons.person;
    }
  }
}