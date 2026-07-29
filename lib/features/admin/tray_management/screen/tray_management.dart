import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/tray_management_shimmer.dart';
import '../bloc/tray_management_bloc.dart';
import '../bloc/tray_management_event.dart';
import '../bloc/tray_management_state.dart';
import '../services/tray_management_service.dart';
import '../models/tray_inventory_model.dart';

class TrayManagementScreen extends StatelessWidget {
  const TrayManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TrayManagementBloc(TrayManagementService())
            ..add(FetchInventoryEvent()),
      child: const TrayManagementView(),
    );
  }
}

class TrayManagementView extends StatefulWidget {
  const TrayManagementView({Key? key}) : super(key: key);

  @override
  State<TrayManagementView> createState() => _TrayManagementViewState();
}

class _TrayManagementViewState extends State<TrayManagementView> {
  bool showWarehouseDetails = false;
  bool showBranchDetails = false;
  bool showTransitDetails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Tray Management',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<TrayManagementBloc, TrayManagementState>(
        builder: (context, state) {
          if (state.isLoading && state.inventory.isEmpty) {
            return const TrayManagementShimmer();
          }

          final inventory = state.inventory;
          final pendingReturns = state.pendingReturns;

          final warehouses = inventory
              .where((item) => item.locationType == 'WAREHOUSE')
              .toList();
          final branches = inventory
              .where((item) => item.locationType == 'BRANCH')
              .toList();
          final transit = inventory
              .where((item) => item.locationType == 'TRANSIT')
              .toList();

          // Calculate totals
          final totalWarehousePlastic = warehouses.fold<int>(
            0,
            (sum, item) => sum + item.plasticTrayCount,
          );
          final totalWarehouseFilledPlastic = warehouses.fold<int>(
            0,
            (sum, item) => sum + item.filledPlasticCount,
          );
          final totalWarehousePaper = warehouses.fold<int>(
            0,
            (sum, item) => sum + item.paperTrayCount,
          );
          final totalWarehouseFilledPaper = warehouses.fold<int>(
            0,
            (sum, item) => sum + item.filledPaperCount,
          );
          final totalWarehouseCovers = warehouses.fold<int>(
            0,
            (sum, item) => sum + item.coverCount,
          );

          final totalBranchPlastic = branches.fold<int>(
            0,
            (sum, item) => sum + item.plasticTrayCount,
          );
          final totalBranchFilledPlastic = branches.fold<int>(
            0,
            (sum, item) => sum + item.filledPlasticCount,
          );
          final totalBranchPaper = branches.fold<int>(
            0,
            (sum, item) => sum + item.paperTrayCount,
          );
          final totalBranchFilledPaper = branches.fold<int>(
            0,
            (sum, item) => sum + item.filledPaperCount,
          );
          final totalBranchCovers = branches.fold<int>(
            0,
            (sum, item) => sum + item.coverCount,
          );

          final totalTransitPlastic = transit.fold<int>(
            0,
            (sum, item) => sum + item.plasticTrayCount,
          );
          final totalTransitFilledPlastic = transit.fold<int>(
            0,
            (sum, item) => sum + item.filledPlasticCount,
          );
          final totalTransitPaper = transit.fold<int>(
            0,
            (sum, item) => sum + item.paperTrayCount,
          );
          final totalTransitFilledPaper = transit.fold<int>(
            0,
            (sum, item) => sum + item.filledPaperCount,
          );
          final totalTransitCovers = transit.fold<int>(
            0,
            (sum, item) => sum + item.coverCount,
          );

          // Low stock locations (Warehouse and Branch where plastic or paper empty count < 5)
          const int lowStockThreshold = 5;
          final lowStockLocations = [...warehouses, ...branches]
              .where(
                (item) =>
                    item.plasticTrayCount < lowStockThreshold ||
                    item.paperTrayCount < lowStockThreshold,
              )
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TrayManagementBloc>().add(FetchInventoryEvent());
            },
            color: const Color(0xFFFFD600),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Cards (Warehouse, Branch, Transit)
                  _buildDashboardCard(
                    title: '🏢 Warehouse Stock',
                    isExpanded: showWarehouseDetails,
                    onToggle: () => setState(
                      () => showWarehouseDetails = !showWarehouseDetails,
                    ),
                    filledPlastic: totalWarehouseFilledPlastic,
                    emptyPlastic: totalWarehousePlastic,
                    filledPaper: totalWarehouseFilledPaper,
                    emptyPaper: totalWarehousePaper,
                    covers: totalWarehouseCovers,
                    locations: warehouses,
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardCard(
                    title: '🏪 Branch Stock',
                    isExpanded: showBranchDetails,
                    onToggle: () =>
                        setState(() => showBranchDetails = !showBranchDetails),
                    filledPlastic: totalBranchFilledPlastic,
                    emptyPlastic: totalBranchPlastic,
                    filledPaper: totalBranchFilledPaper,
                    emptyPaper: totalBranchPaper,
                    covers: totalBranchCovers,
                    locations: branches,
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardCard(
                    title: '🚚 Transit Stock',
                    isExpanded: showTransitDetails,
                    onToggle: () => setState(
                      () => showTransitDetails = !showTransitDetails,
                    ),
                    filledPlastic: totalTransitFilledPlastic,
                    emptyPlastic: totalTransitPlastic,
                    filledPaper: totalTransitFilledPaper,
                    emptyPaper: totalTransitPaper,
                    covers: totalTransitCovers,
                    locations: transit,
                  ),
                  const SizedBox(height: 24),

                  // Alerts Section
                  if (lowStockLocations.isNotEmpty ||
                      pendingReturns.isNotEmpty) ...[
                    const Text(
                      'Alerts & Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Low Stock Alert
                    if (lowStockLocations.isNotEmpty)
                      _buildLowStockAlert(lowStockLocations, lowStockThreshold),
                    if (lowStockLocations.isNotEmpty &&
                        pendingReturns.isNotEmpty)
                      const SizedBox(height: 16),
                    // Pending Returns Alert
                    if (pendingReturns.isNotEmpty)
                      _buildPendingReturnsAlert(pendingReturns),
                  ] else if (!state.isLoading) ...[
                    // All good alert
                    _buildAllGoodAlert(),
                  ],
                  const SizedBox(height: 24),

                  // Inventory Details Table
                  _buildInventoryDetailsTable(inventory),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required int filledPlastic,
    required int emptyPlastic,
    required int filledPaper,
    required int emptyPaper,
    required int covers,
    required List<TrayInventoryModel> locations,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isExpanded ? 'Hide Details ▲' : 'View Details ▼',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grid items
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                children: [
                  _buildGridTile(
                    'PLASTIC WITH EGG',
                    filledPlastic,
                    const Color(0xFFF0FDF4),
                    const Color(0xFFBBF7D0),
                    const Color(0xFF166534),
                  ),
                  _buildGridTile(
                    'EMPTY PLASTIC',
                    emptyPlastic,
                    const Color(0xFFF0FDF4),
                    const Color(0xFFBBF7D0),
                    const Color(0xFF166534),
                  ),
                  _buildGridTile(
                    'PAPER WITH EGG',
                    filledPaper,
                    const Color(0xFFFFFBEB),
                    const Color(0xFFFDE68A),
                    const Color(0xFF92400E),
                  ),
                  _buildGridTile(
                    'EMPTY PAPER',
                    emptyPaper,
                    const Color(0xFFFFFBEB),
                    const Color(0xFFFDE68A),
                    const Color(0xFF92400E),
                  ),
                  _buildGridTile(
                    'COVERS',
                    covers,
                    const Color(0xFFEFF6FF),
                    const Color(0xFFBFDBFE),
                    const Color(0xFF1E40AF),
                  ),
                ],
              ),

              // Details section
              if (isExpanded) ...[
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                if (locations.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No location inventory data available.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  )
                else ...[
                  // Detail list header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        _buildDetailHeaderCol('P. Egg'),
                        _buildDetailHeaderCol('P. Empty'),
                        _buildDetailHeaderCol('Pa. Egg'),
                        _buildDetailHeaderCol('Pa. Empty'),
                        _buildDetailHeaderCol('Covers'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Detail items
                  ...locations.map(
                    (loc) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.locationName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildDetailValCol(
                            loc.filledPlasticCount,
                            const Color(0xFFF0FDF4),
                            const Color(0xFFBBF7D0),
                            const Color(0xFF166534),
                          ),
                          _buildDetailValCol(
                            loc.plasticTrayCount,
                            const Color(0xFFF0FDF4),
                            const Color(0xFFBBF7D0),
                            const Color(0xFF166534),
                          ),
                          _buildDetailValCol(
                            loc.filledPaperCount,
                            const Color(0xFFFFFBEB),
                            const Color(0xFFFDE68A),
                            const Color(0xFF92400E),
                          ),
                          _buildDetailValCol(
                            loc.paperTrayCount,
                            const Color(0xFFFFFBEB),
                            const Color(0xFFFDE68A),
                            const Color(0xFF92400E),
                          ),
                          _buildDetailValCol(
                            loc.coverCount,
                            const Color(0xFFEFF6FF),
                            const Color(0xFFBFDBFE),
                            const Color(0xFF1E40AF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridTile(
    String label,
    int count,
    Color bg,
    Color border,
    Color text,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: text,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              color: text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeaderCol(String text) {
    return SizedBox(
      width: 50,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildDetailValCol(int val, Color bg, Color border, Color text) {
    return Container(
      width: 50,
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        '$val',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildLowStockAlert(
    List<TrayInventoryModel> locations,
    int threshold,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'Low Stock Alert',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE68A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${locations.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: locations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final loc = locations[idx];
              final plasticLow = loc.plasticTrayCount < threshold;
              final paperLow = loc.paperTrayCount < threshold;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFEF3C7)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.locationName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.locationType,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Plastic: ${loc.plasticTrayCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: plasticLow
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Paper: ${loc.paperTrayCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: paperLow
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPendingReturnsAlert(List<dynamic> returns) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔄', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'Pending Tray Returns',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E40AF),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFDBFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${returns.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: returns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final ret = returns[idx];
              String dateFormatted = "-";
              if (ret['return_date'] != null) {
                try {
                  dateFormatted = DateFormat(
                    'dd MMM yy',
                  ).format(DateTime.parse(ret['return_date']));
                } catch (_) {}
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ret['return_from_name']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PENDING',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildReturnMetaItem(
                          'Type',
                          ret['tray_type']?.toString() ?? '-',
                        ),
                        const SizedBox(width: 16),
                        _buildReturnMetaItem(
                          'Qty',
                          ret['quantity']?.toString() ?? '-',
                        ),
                        const SizedBox(width: 16),
                        _buildReturnMetaItem(
                          'To',
                          ret['return_to']?.toString() ?? '-',
                        ),
                        if (dateFormatted != "-") ...[
                          const SizedBox(width: 16),
                          _buildReturnMetaItem('Date', dateFormatted),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReturnMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildAllGoodAlert() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        children: [
          Text('✅', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'All Good! No low stock or pending tray issues.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF15803D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryDetailsTable(List<TrayInventoryModel> inventory) {
    final filtered = inventory
        .where((item) => item.locationType != 'TRAY_HUB')
        .toList();
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No inventory records found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else if (isDesktop)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Location',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Plastic (With Egg)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Plastic (Empty)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Paper (With Egg)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Paper (Empty)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Covers',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Last Updated',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: filtered.map((item) {
                    final isWarehouse = item.locationType == 'WAREHOUSE';
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item.locationName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isWarehouse
                                  ? const Color(0xFFE0E7FF)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.locationType,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isWarehouse
                                    ? const Color(0xFF3730A3)
                                    : const Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text('${item.filledPlasticCount}')),
                        DataCell(Text('${item.plasticTrayCount}')),
                        DataCell(Text('${item.filledPaperCount}')),
                        DataCell(Text('${item.paperTrayCount}')),
                        DataCell(Text('${item.coverCount}')),
                        DataCell(
                          Text(
                            DateFormat(
                              'M/d/yyyy, h:mm a',
                            ).format(item.updatedAt.toLocal()),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                itemBuilder: (context, idx) {
                  final item = filtered[idx];
                  final isWarehouse = item.locationType == 'WAREHOUSE';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.locationName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isWarehouse
                                    ? const Color(0xFFE0E7FF)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.locationType,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isWarehouse
                                      ? const Color(0xFF3730A3)
                                      : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCompactTableCol(
                              'P. Egg / Empty',
                              '${item.filledPlasticCount} / ${item.plasticTrayCount}',
                            ),
                            _buildCompactTableCol(
                              'Pa. Egg / Empty',
                              '${item.filledPaperCount} / ${item.paperTrayCount}',
                            ),
                            _buildCompactTableCol(
                              'Covers',
                              '${item.coverCount}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last Updated: ${DateFormat('M/d/yyyy, h:mm a').format(item.updatedAt.toLocal())}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTableCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
