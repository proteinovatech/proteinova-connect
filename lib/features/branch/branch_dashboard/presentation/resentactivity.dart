import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/bloc/dashboard_bloc.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/bloc/dashboard_event.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/bloc/dashboard_state.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/repository/dashboard_repository.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/activityitem.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/recent_activity_skeleton.dart';

class Resentactivity extends StatefulWidget {
  const Resentactivity({super.key});

  @override
  State<Resentactivity> createState() =>
      _ResentactivityState();
}

class _ResentactivityState
    extends State<Resentactivity> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          AppColors.background,

      appBar: AppBar(

        backgroundColor:
            AppColors.background,

        scrolledUnderElevation: 0,

        title: const Text(
          "Recent Activity",
        ),
      ),

      body:  BlocProvider(
  create: (_) => DashboardBloc(
    DashboardRepository(DioClient().dio),
  )..add(FetchDashboardEvent()),

  child: BlocBuilder<DashboardBloc, DashboardState>(
    builder: (context, state) {

      // LOADING
      if (state is DashboardLoading) {
        return const Center(
          child: RecentActivitySkeleton(),
        );
      }

      // ERROR
      if (state is DashboardError) {
        return Center(
          child: Text(state.message),
        );
      }

      // SUCCESS
      if (state is DashboardLoaded) {

        final dashboardModel = state.dashboard;

        if (dashboardModel.recentActivity.isEmpty) {
          return const Center(
            child: Text(
              "No Recent Activity",
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12),

                  child: RefreshIndicator(
                    color: Colors.blue,

  onRefresh: () async {
    context.read<DashboardBloc>()
                  .add(FetchDashboardEvent());
  },
                    child: ListView.builder(
                      itemCount: dashboardModel.recentActivity.length,
                    
                      itemBuilder: (context, index) {
                        final activity = dashboardModel.recentActivity[index];
                    
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
                  )
                  );
                  }
                 return const SizedBox();
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