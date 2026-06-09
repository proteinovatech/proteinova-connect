import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/dispatch_planning_page.dart';
import 'package:proteinova_connect/services/dispatch_service.dart';

class DistributionPage extends StatefulWidget {
  const DistributionPage({super.key});

  @override
  State<DistributionPage> createState() => _DistributionPageState();
}

class _DistributionPageState extends State<DistributionPage> {
  Map<String, dynamic> dashboardCards = {
    "active_vehicles": 0,
    "todays_dispatches": 0,
    "in_transit": 0,
    "total_delivered_today": 0,
    "today_branch_sales_count": 0,
    "today_branch_qty": 0,
    "today_customer_sales_count": 0,
    "today_customer_qty": 0,
    "total_sales_count": 0,
  };

  List<dynamic> dispatches = [];
  int totalCount = 0;
  bool loading = true;
  bool isFetching = true;

  // Modal / Detail Dialog Config
  bool isModalOpen = false;
  String modalTitle = "";
  String modalFilterType =
      ""; // 'branch_today', 'customer_today', 'transit', 'total_sales'
  String totalSalesFilter = "All"; // 'All', 'Branch', 'Customer'

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && !loading && !isModalOpen) {
        fetchDashboardData(isAuto: true);
      }
    });
  }

  Future<void> fetchDashboardData({bool isAuto = false}) async {
    if (!isAuto) {
      setState(() {
        loading = true;
        isFetching = true;
      });
    }

    try {
      // Fetch up to 100 dispatches to populate the details accurately
      final data = await DispatchService.fetchDispatchDashboard(limit: 100);
      if (mounted && data != null) {
        setState(() {
          dashboardCards = Map<String, dynamic>.from(data['cards'] ?? {});
          dispatches = List<dynamic>.from(data['dispatches'] ?? []);
          totalCount =
              int.tryParse(data['pagination']?['total']?.toString() ?? '0') ??
              0;
          loading = false;
          isFetching = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dispatch dashboard: $e");
      if (mounted) {
        setState(() {
          loading = false;
          isFetching = false;
        });
      }
    }
  }

  Color getDisClass(String? status) {
    final s = (status ?? '').toUpperCase();
    if (s == 'DELIVERED') return Colors.green;
    return Colors.blue;
  }

  void handleCardClick(String title, String filterType) {
    setState(() {
      totalSalesFilter = "All";
      modalTitle = title;
      modalFilterType = filterType;
      isModalOpen = true;
    });
    _showModalDetails();
  }

  List<dynamic> getModalData() {
    if (modalFilterType.isEmpty) return [];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    switch (modalFilterType) {
      case 'branch_today':
        return dispatches.where((d) {
          if (d['date'] == null) return false;
          final dDate = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.parse(d['date'].toString()).toLocal());
          final hasBranch =
              d['destination_branch'] != null &&
              d['destination_branch'].toString().isNotEmpty;
          return dDate == today && hasBranch;
        }).toList();

      case 'customer_today':
        return dispatches.where((d) {
          if (d['date'] == null) return false;
          final dDate = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.parse(d['date'].toString()).toLocal());
          final hasBranch =
              d['destination_branch'] != null &&
              d['destination_branch'].toString().isNotEmpty;
          return dDate == today && !hasBranch;
        }).toList();

      case 'transit':
        return dispatches
            .where((d) => d['status'].toString().toUpperCase() == 'IN_TRANSIT')
            .toList();

      case 'total_sales':
        var filtered = dispatches;
        if (totalSalesFilter == 'Branch') {
          filtered = dispatches
              .where(
                (d) =>
                    d['destination_branch'] != null &&
                    d['destination_branch'].toString().isNotEmpty,
              )
              .toList();
        } else if (totalSalesFilter == 'Customer') {
          filtered = dispatches
              .where(
                (d) =>
                    d['destination_branch'] == null ||
                    d['destination_branch'].toString().isEmpty,
              )
              .toList();
        }
        return filtered;

      default:
        return dispatches;
    }
  }

  void _showModalDetails() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final modalData = getModalData();
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              modalTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 15),
                            if (modalFilterType == 'total_sales')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                height: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFD1D5DB),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: totalSalesFilter,
                                    items: ['All', 'Branch', 'Customer'].map((
                                      String val,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: val,
                                        child: Text(
                                          val,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setModalState(() {
                                        totalSalesFilter = newValue ?? 'All';
                                      });
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            setState(() => isModalOpen = false);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Modal Table Content
                    Expanded(
                      child: modalData.isEmpty
                          ? const Center(
                              child: Text(
                                "No records found for this filter.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    const Color(0xFFF1F5F9),
                                  ),
                                  columns: _buildModalColumns(),
                                  rows: modalData.map((item) {
                                    return DataRow(
                                      cells: _buildModalCells(item),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() => isModalOpen = false);
    });
  }

  List<DataColumn> _buildModalColumns() {
    if (modalFilterType == 'branch_today') {
      return const [
        DataColumn(
          label: Text(
            'Invoice ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Branch Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Vehicle & Driver',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Quantity',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Dispatch Time',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ];
    } else if (modalFilterType == 'customer_today') {
      return const [
        DataColumn(
          label: Text(
            'Invoice ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Customer Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Vehicle & Driver',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Quantity',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Delivery Time',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ];
    } else if (modalFilterType == 'transit') {
      return const [
        DataColumn(
          label: Text(
            'Dispatch ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Vehicle & Driver',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Destination',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Quantity',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Estimated Arrival',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Live Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ];
    } else {
      // total_sales
      return const [
        DataColumn(
          label: Text('Sale ID', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'Sale Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Customer/Branch',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Vehicle & Driver',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Quantity',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Date & Time',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ];
    }
  }

  List<DataCell> _buildModalCells(dynamic item) {
    final vd = item['vehicle_driver']?.toString() ?? "";
    final parts = vd.split('(');
    final vehicle = parts[0].trim();
    final driver = parts.length > 1
        ? parts[1].replaceAll(')', '').trim()
        : 'Unassigned';

    final id = item['dispatch_id'] ?? item['invoice_id'] ?? 'N/A';
    final qty = int.tryParse(item['total_qty']?.toString() ?? '0') ?? 0;
    final status = String.fromCharCodes(
      item['status']?.toString().codeUnits ?? [],
    );

    final dateStr = item['date'] != null
        ? DateFormat(
            'hh:mm a',
          ).format(DateTime.parse(item['date'].toString()).toLocal())
        : 'N/A';
    final fullDate = item['date'] != null
        ? DateFormat(
            'yyyy-MM-dd hh:mm a',
          ).format(DateTime.parse(item['date'].toString()).toLocal())
        : 'N/A';

    if (modalFilterType == 'branch_today') {
      return [
        DataCell(Text(id.toString())),
        DataCell(Text(item['destination_branch']?.toString() ?? 'N/A')),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vehicle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                driver,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
        DataCell(Text(qty.toLocaleString())),
        DataCell(Text(dateStr)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getDisClass(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: getDisClass(status),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ];
    } else if (modalFilterType == 'customer_today') {
      return [
        DataCell(Text(id.toString())),
        DataCell(Text(item['customer_name']?.toString() ?? 'Walk-in')),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vehicle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                driver,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
        DataCell(Text(qty.toLocaleString())),
        DataCell(Text(item['delivery_time']?.toString() ?? dateStr)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getDisClass(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: getDisClass(status),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ];
    } else if (modalFilterType == 'transit') {
      return [
        DataCell(Text(id.toString())),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vehicle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                driver,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
        DataCell(
          Text(item['destination_branch'] ?? item['customer_name'] ?? 'N/A'),
        ),
        DataCell(Text(qty.toLocaleString())),
        DataCell(Text(item['estimated_arrival']?.toString() ?? 'N/A')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getDisClass(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: getDisClass(status),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ];
    } else {
      // total_sales
      final hasBranch =
          item['destination_branch'] != null &&
          item['destination_branch'].toString().isNotEmpty;
      return [
        DataCell(Text(id.toString())),
        DataCell(Text(hasBranch ? 'Branch' : 'Customer')),
        DataCell(
          Text(
            item['destination_branch'] ?? item['customer_name'] ?? 'Walk-in',
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vehicle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                driver,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
        DataCell(Text(qty.toLocaleString())),
        DataCell(Text(fullDate)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getDisClass(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: getDisClass(status),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Warehouse Sales Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DispatchPlanningPage(),
                  ),
                ).then((value) {
                  if (value == true) {
                    fetchDashboardData();
                  }
                });
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text(
                "Create New Sales",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: loading && isFetching
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.amber600),
            )
          : RefreshIndicator(
              onRefresh: fetchDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Four Stat Cards Row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final int crossAxisCount = width >= 900 ? 4 : 2;
                        final double childAspectRatio = width >= 900
                            ? 2.0
                            : (width >= 600 ? 2.5 : 1.35);
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          children: [
                            _buildStatCard(
                              title: "Today Sales (Branch)",
                              count:
                                  dashboardCards['today_branch_sales_count'] ??
                                  0,
                              subtitle:
                                  "Qty: ${dashboardCards['today_branch_qty'] ?? 0}",
                              icon: Icons.local_shipping_outlined,
                              color: const Color(0xFF3B82F6),
                              onTap: () => handleCardClick(
                                "Today Sales (Branch)",
                                "branch_today",
                              ),
                            ),
                            _buildStatCard(
                              title: "Today Sales (Customer)",
                              count:
                                  dashboardCards['today_customer_sales_count'] ??
                                  0,
                              subtitle:
                                  "Qty: ${dashboardCards['today_customer_qty'] ?? 0}",
                              icon: Icons.send_outlined,
                              color: const Color(0xFF10B981),
                              onTap: () => handleCardClick(
                                "Today Sales (Customer)",
                                "customer_today",
                              ),
                            ),
                            _buildStatCard(
                              title: "In Transit",
                              count: dashboardCards['in_transit'] ?? 0,
                              subtitle: "Ongoing deliveries",
                              icon: Icons.assignment_outlined,
                              color: const Color(0xFFF59E0B),
                              onTap: () =>
                                  handleCardClick("In Transit", "transit"),
                            ),
                            _buildStatCard(
                              title: "Total Sales",
                              count:
                                  dashboardCards['total_sales_count'] ??
                                  totalCount,
                              subtitle: "Branch + Customer",
                              icon: Icons.inventory_2_outlined,
                              color: const Color(0xFF8B5CF6),
                              onTap: () =>
                                  handleCardClick("Total Sales", "total_sales"),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Main Table Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Recent & Planned Dispatches",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          dispatches.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Text(
                                      "No dispatches found",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: dispatches.take(10).map((item) {
                                    final vd =
                                        item['vehicle_driver']?.toString() ??
                                        "";
                                    final parts = vd.split('(');
                                    final vehicle = parts[0].trim();
                                    final driver = parts.length > 1
                                        ? parts[1].replaceAll(')', '').trim()
                                        : 'Unassigned';

                                    final dateText = item['date'] != null
                                        ? DateFormat('yyyy-MM-dd').format(
                                            DateTime.parse(
                                              item['date'].toString(),
                                            ).toLocal(),
                                          )
                                        : 'N/A';

                                    final status =
                                        item['status']
                                            ?.toString()
                                            .toUpperCase() ??
                                        '';
                                    final qty =
                                        int.tryParse(
                                          item['total_qty']?.toString() ?? '0',
                                        ) ??
                                        0;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  item['dispatch_id']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: getDisClass(
                                                      status,
                                                    ).withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    status == 'DELIVERED'
                                                        ? 'Delivered'
                                                        : 'Transit',
                                                    style: TextStyle(
                                                      color: getDisClass(
                                                        status,
                                                      ),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 16,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  dateText,
                                                  style: const TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 16,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item['destination_branch']
                                                            ?.toString() ??
                                                        item['customer_name']
                                                            ?.toString() ??
                                                        'Customer/Walk-in',
                                                    style: const TextStyle(
                                                      color: Color(0xFF1E293B),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.directions_car_outlined,
                                                  size: 16,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    vehicle.isNotEmpty
                                                        ? '$vehicle ($driver)'
                                                        : 'Unassigned',
                                                    style: const TextStyle(
                                                      color: Color(0xFF64748B),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              height: 24,
                                              color: Color(0xFFE2E8F0),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Total Qty",
                                                  style: TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  qty.toLocaleString(),
                                                  style: const TextStyle(
                                                    color: Color(0xFF1E293B),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      count.toLocaleString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

extension IntExtension on int {
  String toLocaleString() {
    final formatter = NumberFormat('#,##,###');
    return formatter.format(this);
  }
}
