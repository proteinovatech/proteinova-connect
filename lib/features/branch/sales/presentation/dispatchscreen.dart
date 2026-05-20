import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/dispatch/dispatch_bloc.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/dispatch/dispatch_event.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/dispatch/dispatch_state.dart';
import 'package:proteinova_connect/features/branch/sales/widget/dispatchcard2.dart';
import 'package:proteinova_connect/features/branch/sales/widget/dispatchcard3.dart';

import '../data/repository/sales_repository.dart';

class Dispatchscreen extends StatefulWidget {
  const Dispatchscreen({super.key});

  @override
  State<Dispatchscreen> createState() => _DispatchscreenState();
}

class _DispatchscreenState extends State<Dispatchscreen> {
  Size get size => MediaQuery.of(context).size;
  
  final SalesRepository _repository = SalesRepository();

  

  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
  create: (_) => DispatchBloc(
    _repository,
  )..add(FetchDispatchEvent()),

  child: BlocBuilder<
      DispatchBloc,
      DispatchState>(
    builder: (context, state) {

      // LOADING
      if (state is DispatchLoading) {
        return const Scaffold(
          body: Center(
            child:
                CircularProgressIndicator(),
          ),
        );
      }

      // ERROR
      if (state is DispatchError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Text(
                  "Error: ${state.message}",
                ),

                ElevatedButton(
                  onPressed: () {
                    context
                        .read<DispatchBloc>()
                        .add(
                          FetchDispatchEvent(),
                        );
                  },

                  child: const Text(
                    "Retry",
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // SUCCESS
      if (state is DispatchLoaded) {

        final dispatches =
            state.dispatches;
    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        title: Image.asset("assets/erplogo.png", height: 40),
        actions: const [
          Icon(Icons.search_outlined, color: Colors.black),
          SizedBox(width: 10),
          Icon(Icons.notifications_outlined, color: Colors.black),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xffe0e0e0),
            child: Icon(Icons.person, size: 20, color: Color(0xffffffff)),
          ),
          SizedBox(width: 10),
        ],
      ),
      body:  RefreshIndicator(
              onRefresh:() async {

              context
                  .read<DispatchBloc>()
                  .add(
                    RefreshDispatchEvent(),
                  );
            },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      _buildStatsRows(dispatches),
                      SizedBox(height: size.height * 0.05),
                      _buildDispatchListHeader(),
                      SizedBox(height: size.height * 0.02),
                      dispatches.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text("No Active Dispatches Found"),
                              ),
                            )
                          : ListView.builder(
                              itemCount: dispatches.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final item = dispatches[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: DispatchCard3(
                                    id: "DS-${item["dispatch_id"] ?? item["id"]}",
                                    status:
                                        item["status"]?.toString() ?? "Pending",
                                    branch:
                                        item["destination"]?.toString() ??
                                        "N/A",
                                    date:
                                        item["dispatch_date"]?.toString() ??
                                        "N/A",
                                    totalQty:
                                        "${item["total_trays"] ?? 0} Trays",
                                    vehicleDriver:
                                        item["vehicle_driver"]?.toString() ??
                                        "N/A",
                                    showFullActions: true,
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
          }

      return const SizedBox();
    },
  ),
);
  }

  Widget _buildStatsRows( List<dynamic> dispatches, ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Dispatchcard2(
                title: "Active",
                value: "12/15",
                subtitle: "Vehicles",
                icon: Icons.local_shipping_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.grey,
              ),
            ),
            SizedBox(width: size.width * 0.05),
            Expanded(
              child: Dispatchcard2(
                title: "Today's",
                value: dispatches.length.toString(),
                subtitle: "Dispatches",
                icon: Icons.inventory_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
        Row(
          children: [
            Expanded(
              child: Dispatchcard2(
                title: "In",
                value: "120",
                subtitle: "Transit",
                icon: Icons.send_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.grey,
              ),
            ),
            SizedBox(width: size.width * 0.05),
            Expanded(
              child: Dispatchcard2(
                title: "Delivered",
                value: "12,300",
                subtitle: "Total",
                icon: Icons.inventory_2_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
    
  }
  

  Widget _buildDispatchListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Active dispatches", style: AppTextStyles.headingText22),
        Row(
          children: [
            _buildActionIcon(Icons.search),
            const SizedBox(width: 8),
            _buildActionIcon(Icons.filter_alt_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, color: Colors.grey, size: 20),
    );
    
  }
  
}
