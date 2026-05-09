import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/dispatch_planning_page.dart';
import 'package:proteinova_connect/features/admin/Distribution/widget/dispatchcard_widget.dart';
import 'package:proteinova_connect/features/admin/Distribution/widget/statcard_widget.dart';

class DistributionPage extends StatelessWidget {
  const DistributionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xffF6F7FB),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 90,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text(
              "Distribution Dashboard",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Monitor and manage all dispatches",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),

            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DispatchPlanningPage(),
                  ),
                );
              },

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xffFFD600),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.add, size: 18, color: Colors.black),

                    SizedBox(width: 6),

                    Text(
                      "Create Dispatch",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      /// BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              /// TOP CARDS
              Row(
                children: [
                  Expanded(
                    child: statCard(
                      icon: Icons.local_shipping,
                      iconColor: Colors.blue,
                      title: "Active Vehicles",
                      count: "1",
                      subtitle: "Vehicles currently available",
                      context: context,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: statCard(
                      icon: Icons.send,
                      iconColor: Colors.purple,
                      title: "Today's Dispatches",
                      count: "0",
                      subtitle: "Dispatched today",
                      context: context,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: statCard(
                      icon: Icons.local_shipping_outlined,
                      iconColor: Colors.green,
                      title: "In Transit",
                      count: "1",
                      subtitle: "Deliveries in progress",
                      context: context,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: statCard(
                      icon: Icons.inventory_2_outlined,
                      iconColor: Colors.grey,
                      title: "Total Dispatches",
                      count: "1",
                      subtitle: "All time dispatches",
                      context: context,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              /// DISPATCH SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.03),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Recent & Planned Dispatches",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// SEARCH + FILTER
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,

                            padding: const EdgeInsets.symmetric(horizontal: 14),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),

                              border: Border.all(color: Colors.grey.shade300),
                            ),

                            child: const Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                  size: 20,
                                ),

                                SizedBox(width: 10),

                                Text(
                                  "Search dispatches...",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          height: 48,
                          width: 90,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),

                            border: Border.all(color: Colors.grey.shade300),
                          ),

                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Icon(Icons.tune, size: 18),

                              SizedBox(width: 6),

                              Text(
                                "Filter",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// DISPATCH LIST
                    dispatchCard(
                      id: "DSP-1",
                      date: "30/4/2026",
                      branch: "Branch 034",
                      vehicle: "TN 32 B 2134",
                      driver: "Mani",
                      qty: "1,530",
                      status: "Transit",
                      statusColor: Colors.blue,
                    ),

                    dispatchCard(
                      id: "DSP-2",
                      date: "29/4/2026",
                      branch: "Branch 012",
                      vehicle: "TN 45 AB 6789",
                      driver: "Suresh",
                      qty: "980",
                      status: "Delivered",
                      statusColor: Colors.green,
                    ),

                    dispatchCard(
                      id: "DSP-3",
                      date: "28/4/2026",
                      branch: "Branch 056",
                      vehicle: "TN 01 CD 4321",
                      driver: "Ramesh",
                      qty: "2,100",
                      status: "Pending",
                      statusColor: Colors.orange,
                    ),

                    dispatchCard(
                      id: "DSP-4",
                      date: "27/4/2026",
                      branch: "Branch 021",
                      vehicle: "TN 99 XY 1000",
                      driver: "Arun",
                      qty: "1,250",
                      status: "Cancelled",
                      statusColor: Colors.grey,
                    ),

                    const SizedBox(height: 20),

                    /// PAGINATION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Expanded(
                          child: Text(
                            "Showing 1 to 4 of 4 dispatches",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),

                        Row(
                          children: [
                            pageButton(Icons.chevron_left),

                            const SizedBox(width: 8),

                            Container(
                              height: 38,
                              width: 38,

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),

                                border: Border.all(color: Colors.blue),
                              ),

                              child: const Center(
                                child: Text(
                                  "1",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            pageButton(Icons.chevron_right),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
