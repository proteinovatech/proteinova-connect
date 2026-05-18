import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/add_asset_Button.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/total_tracked_bottomsheet_widget.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/asset_table_widget.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/currently_in_use_bottomsheet.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/damaged_bottomsheet.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/filter_button_widget.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/widget/under_maintenance_bottomsheet.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_expense_management_skeleton_loader.dart';

import '../data/asset_repository.dart';
import '../models/asset_model.dart';

class AssetManagementPage extends StatefulWidget {
  const AssetManagementPage({super.key});

  @override
  State<AssetManagementPage> createState() => _AssetManagementPageState();
}

class _AssetManagementPageState extends State<AssetManagementPage> {
  final AssetRepository _repository = AssetRepository();
  List<AssetModel> assets = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedBranch = 'All Branches';
  String selectedCategory = 'All Categories';
  String selectedStatus = 'All Statuses';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final list = await _repository.fetchAssets();
      setState(() {
        assets = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching assets: $e')));
      }
    }
  }

  int get _totalTracked => assets.length;
  int get _currentlyInUse => assets.where((a) => a.status == 'In Use').length;
  int get _underMaintenance =>
      assets.where((a) => a.status == 'Maintenance').length;
  int get _damaged => assets.where((a) => a.status == 'Damaged').length;

  List<String> get _availableBranches {
    final list = assets.map((a) => a.location).toSet().toList();
    list.sort();
    return ['All Branches', ...list];
  }

  List<String> get _availableCategories {
    final list = assets.map((a) => a.category).toSet().toList();
    list.sort();
    return ['All Categories', ...list];
  }

  List<AssetModel> get _filteredAssets {
    return assets.where((a) {
      // Search filter
      final query = searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          a.name.toLowerCase().contains(query) ||
          a.assetId.toLowerCase().contains(query) ||
          a.category.toLowerCase().contains(query);

      // Branch filter
      final matchesBranch =
          selectedBranch == 'All Branches' || a.location == selectedBranch;

      // Category filter
      final matchesCategory =
          selectedCategory == 'All Categories' ||
          a.category == selectedCategory;

      // Status filter
      final matchesStatus =
          selectedStatus == 'All Statuses' || a.status == selectedStatus;

      return matchesSearch && matchesBranch && matchesCategory && matchesStatus;
    }).toList();
  }

  // ── Bottom Sheet helpers ──────────────────────────────────────────────────

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TotalTrackedBottomsheetWidget(
        title: 'Total Tracked Assets',
        icon: Icons.inventory_2_outlined,
        iconColor: Colors.blue,
        assets: assets,
      ),
    );
  }

  void _showInUseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrentlyInUseBottomSheet(
        assets: assets.where((a) => a.status == 'In Use').toList(),
      ),
    );
  }

  void _showMaintenanceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnderMaintenanceBottomSheet(
        assets: assets.where((a) => a.status == 'Maintenance').toList(),
      ),
    );
  }

  void _showDamagedSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DamagedBottomSheet(
        assets: assets.where((a) => a.status == 'Damaged').toList(),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: AdminExpenseManagementSkeletonLoader());
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Asset Management',
              style: TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: getHeight(context, 4)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffFFF7D6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 14,
                    color: Colors.black,
                  ),
                  SizedBox(width: getWidth(context, 5)),
                  Text(
                    'Admin',
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
              width: getWidth(context, 44),
              height: getHeight(context, 44),
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

      body: isLoading
          ? const AdminExpenseManagementSkeletonLoader()
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// ── STAT CARDS ROW 1 ──────────────────────────────────────
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _showBottomSheet,
                                child: _statCard(
                                  icon: Icons.inventory_2_outlined,
                                  iconColor: Colors.blue,
                                  title: 'Total Tracked Assets',
                                  count: _totalTracked.toString(),
                                ),
                              ),
                            ),
                            SizedBox(width: getWidth(context, 12)),
                            Expanded(
                              child: GestureDetector(
                                onTap: _showInUseSheet,
                                child: _statCard(
                                  icon: Icons.local_shipping_outlined,
                                  iconColor: Colors.green,
                                  title: 'Currently In Use',
                                  count: _currentlyInUse.toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: getHeight(context, 12)),

                      /// ── STAT CARDS ROW 2 ──────────────────────────────────────
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _showMaintenanceSheet,
                                child: _statCard(
                                  icon: Icons.build_outlined,
                                  iconColor: Colors.purple,
                                  title: 'Under Maintenance',
                                  count: _underMaintenance.toString(),
                                ),
                              ),
                            ),
                            SizedBox(width: getWidth(context, 12)),
                            Expanded(
                              child: GestureDetector(
                                onTap: _showDamagedSheet,
                                child: _statCard(
                                  icon: Icons.warning_amber_rounded,
                                  iconColor: Colors.red,
                                  title: 'Damaged',
                                  count: _damaged.toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: getHeight(context, 18)),

                      /// ── ACTION CONTAINER ──────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.10),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            /// Search + Filter
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    onChanged: (value) =>
                                        setState(() => searchQuery = value),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search assets...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                      icon: Icon(
                                        Icons.search,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: getWidth(context, 10)),
                                FilterButtonWidget(
                                  selectedBranch: selectedBranch,
                                  selectedCategory: selectedCategory,
                                  selectedStatus: selectedStatus,
                                  availableBranches: _availableBranches,
                                  availableCategories: _availableCategories,
                                  onFilterChanged: (branch, category, status) {
                                    setState(() {
                                      selectedBranch = branch;
                                      selectedCategory = category;
                                      selectedStatus = status;
                                    });
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: getHeight(context, 14)),

                            /// Add Asset button
                            addAssetButton(context, onAssetAdded: _fetchData),
                          ],
                        ),
                      ),

                      SizedBox(height: getHeight(context, 24)),

                      /// ── ASSET TABLE ───────────────────────────────────────────
                      AssetTableWidget(
                        assets: _filteredAssets,
                        onStatusChanged: _fetchData,
                      ),

                      SizedBox(height: getHeight(context, 30)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ── Stat Card widget ──────────────────────────────────────────────────────

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String count,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.10),
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
              // ignore: deprecated_member_use
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          SizedBox(height: getHeight(context, 16)),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: getHeight(context, 8)),
          Text(
            count,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
