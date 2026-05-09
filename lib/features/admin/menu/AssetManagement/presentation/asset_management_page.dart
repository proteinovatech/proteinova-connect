import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/add_asset_Button.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/total_tracked_bottomsheet_widget.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/asset_table_widget.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/currently_in_use_bottomsheet.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/damaged_bottomsheet.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/filter_button_widget.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/under_maintenance_bottomsheet.dart';

class AssetManagementPage extends StatelessWidget {
  const AssetManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F7),
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
        ),

        titleSpacing: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            /// TITLE
            const Text(
              "Asset Management",

              style: TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            /// ADMIN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

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

                  SizedBox(width: 5),

                  Text(
                    "Admin",

                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),

            child: Container(
              width: 44,
              height: 44,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(14),

                border: Border.all(color: Colors.grey.shade300),
              ),

              child: const Icon(Icons.search, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              /// TOP CARDS
              Row(
                children: [
                  /// ===========================================
                  /// FIRST CARD CLICK → BOTTOM SHEET OPEN
                  /// ===========================================
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,

                          isScrollControlled: true,

                          backgroundColor: Colors.transparent,

                          builder: (context) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.78,
                              minChildSize: 0.60,
                              maxChildSize: 0.95,

                              builder: (context, scrollController) {
                                return TotalTrackedBottomsheetWidget(
                                  title: "Total Tracked Assets",
                                  icon: Icons.inventory_2_outlined,
                                  iconColor: Colors.blue,
                                );
                              },
                            );
                          },
                        );
                      },

                      child: statCard(
                        icon: Icons.inventory_2_outlined,
                        iconColor: Colors.blue,
                        title: "Total Tracked Assets",
                        count: "0",
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,

                          isScrollControlled: true,

                          backgroundColor: Colors.transparent,

                          builder: (context) {
                            return const CurrentlyInUseBottomSheet();
                          },
                        );
                      },

                      child: statCard(
                        icon: Icons.local_shipping_outlined,
                        iconColor: Colors.green,
                        title: "Currently In Use",
                        count: "0",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,

                          isScrollControlled: true,

                          backgroundColor: Colors.transparent,

                          builder: (context) {
                            return const UnderMaintenanceBottomSheet();
                          },
                        );
                      },

                      child: statCard(
                        icon: Icons.build_outlined,
                        iconColor: Colors.purple,
                        title: "Under Maintenance",
                        count: "0",
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,

                          isScrollControlled: true,

                          backgroundColor: Colors.transparent,

                          builder: (context) {
                            return const DamagedBottomSheet();
                          },
                        );
                      },

                      child: statCard(
                        icon: Icons.warning_amber_rounded,
                        iconColor: Colors.red,
                        title: "Damaged",
                        count: "0",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// MAIN CONTAINER
              /// TOP ACTION CONTAINER
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.03),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    /// SEARCH + FILTER
                    Row(
                      children: [
                        /// SEARCH
                        Expanded(
                          flex: 3,

                          child: Container(
                            height: 52,

                            padding: const EdgeInsets.symmetric(horizontal: 14),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),

                              border: Border.all(color: Colors.grey.shade300),
                            ),

                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey.shade500),

                                const SizedBox(width: 10),

                                Text(
                                  "Search assets...",

                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// FILTER
                        FilterButtonWidget(),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// ADD BUTTON
                    addAssetButton(context),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// TABLE + EMPTY CONTAINER
              const AssetTableWidget(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// CARD
  Widget statCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

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
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(height: 16),

          Text(
            title,

            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 8),

          Text(
            count,

            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
