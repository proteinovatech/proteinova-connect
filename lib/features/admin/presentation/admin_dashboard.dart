import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/config/api_config.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_dashboard_skeleton_loader.dart';
import 'package:proteinova_connect/features/admin/presentation/notification_screen.dart';

// Navigation target imports
import 'package:proteinova_connect/features/purchase_dashboard/presentation/newpurchase.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/dispatch_planning_page.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/presentation/sales_entry_page.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';
import 'package:proteinova_connect/features/admin/presentation/Incoming_stock.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  bool isRefreshing = false;
  String selectedFilter = "All Branches";

  @override
  void initState() {
    super.initState();
    _fetchData(showLoader: true);
  }

  Future<void> _fetchData({bool showLoader = true}) async {
    if (showLoader) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
    }
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}${ApiConfig.adminDashboard}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            dashboardData = data;
            isLoading = false;
            isRefreshing = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
            isRefreshing = false;
          });
        }
        debugPrint("Error response from dashboard API: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
      }
      debugPrint("Exception in fetchDashboard: $e");
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    await _fetchData(showLoader: false);
  }

  double _toNumber(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    return parsed ?? 0.0;
  }

  String formatCurrency(num val) {
    return "₹${NumberFormat('#,##,###').format(val)}";
  }

  String formatNumber(num val) {
    return NumberFormat('#,##,###').format(val);
  }

  String formatDate(dynamic dateValue) {
    if (dateValue == null) return "No Date";
    try {
      final date = DateTime.parse(dateValue.toString());
      return DateFormat('dd MMM yyyy • hh:mm a').format(date);
    } catch (_) {
      return "Invalid Date";
    }
  }

  String formatTimeAgo(dynamic dateValue) {
    if (dateValue == null) return "just now";
    try {
      final date = DateTime.parse(dateValue.toString());
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) {
        return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
      }
      if (diff.inHours > 0) {
        return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
      }
      if (diff.inMinutes > 0) {
        return "${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago";
      }
      return "just now";
    } catch (_) {
      return "just now";
    }
  }

  bool _matchesFilter(
    String? recordBranchName,
    String? recordLocationOrDestination,
  ) {
    String name = recordBranchName ?? recordLocationOrDestination ?? '';
    if (name.trim().isEmpty) {
      name = "Warehouse";
    }
    if (selectedFilter == "All Branches") {
      return true;
    }
    if (selectedFilter == "Warehouse") {
      return name.toLowerCase() == "warehouse" ||
          name.toLowerCase() == "direct/warehouse";
    }
    return name.toLowerCase() == selectedFilter.toLowerCase();
  }

  List<dynamic> _getModalData(String activeCard) {
    if (dashboardData == null) return [];
    final categoryGroups = <String, Map<String, dynamic>>{};

    switch (activeCard) {
      case "revenue":
        final list = (dashboardData!['sales_all_breakdown'] as List? ?? []);
        for (var item in list) {
          if (_matchesFilter(item['branch_name']?.toString(), null)) {
            final cat = item['category']?.toString() ?? "N/A";
            categoryGroups.putIfAbsent(
              cat,
              () => {'category': cat, 'total_eggs': 0.0, 'total_amount': 0.0},
            );
            categoryGroups[cat]!['total_eggs'] =
                categoryGroups[cat]!['total_eggs'] +
                _toNumber(item['total_eggs']);
            categoryGroups[cat]!['total_amount'] =
                categoryGroups[cat]!['total_amount'] +
                _toNumber(item['total_amount']);
          }
        }
        return categoryGroups.values.toList();

      case "stock_value":
        final list = (dashboardData!['inventory'] as List? ?? []);
        for (var item in list) {
          if (_matchesFilter(null, item['location']?.toString())) {
            final cat = item['category']?.toString() ?? "N/A";
            categoryGroups.putIfAbsent(
              cat,
              () => {'category': cat, 'total_eggs': 0.0, 'total_value': 0.0},
            );
            categoryGroups[cat]!['total_eggs'] =
                categoryGroups[cat]!['total_eggs'] +
                _toNumber(item['total_eggs']);
            categoryGroups[cat]!['total_value'] =
                categoryGroups[cat]!['total_value'] +
                _toNumber(item['total_value']);
          }
        }
        return categoryGroups.values.toList();

      case "incoming":
        final list = (dashboardData!['incoming'] as List? ?? []);
        for (var item in list) {
          if (_matchesFilter(null, item['destination']?.toString())) {
            final cat = item['category']?.toString() ?? "N/A";
            categoryGroups.putIfAbsent(
              cat,
              () => {'category': cat, 'total_eggs': 0.0},
            );
            categoryGroups[cat]!['total_eggs'] =
                categoryGroups[cat]!['total_eggs'] +
                _toNumber(item['total_eggs']);
          }
        }
        return categoryGroups.values.toList();

      case "damaged":
        final list = (dashboardData!['damaged'] as List? ?? []);
        for (var item in list) {
          if (_matchesFilter(null, item['location']?.toString())) {
            final cat = item['category']?.toString() ?? "N/A";
            categoryGroups.putIfAbsent(
              cat,
              () => {'category': cat, 'total_eggs': 0.0},
            );
            categoryGroups[cat]!['total_eggs'] =
                categoryGroups[cat]!['total_eggs'] +
                _toNumber(item['total_eggs']);
          }
        }
        return categoryGroups.values.toList();

      case "purchase":
        if (selectedFilter == "Warehouse" || selectedFilter == "All Branches") {
          return (dashboardData!['purchase_breakdown'] as List? ?? []);
        }
        return [];

      case "revenue_today":
        return (dashboardData!['sales_today'] as List? ?? [])
            .where(
              (item) => _matchesFilter(item['branch_name']?.toString(), null),
            )
            .toList();

      case "stock_eggs":
        final list = (dashboardData!['inventory'] as List? ?? []);
        for (var item in list) {
          if (_matchesFilter(null, item['location']?.toString())) {
            final cat = item['category']?.toString() ?? "N/A";
            categoryGroups.putIfAbsent(
              cat,
              () => {'category': cat, 'total_eggs': 0.0},
            );
            categoryGroups[cat]!['total_eggs'] =
                categoryGroups[cat]!['total_eggs'] +
                _toNumber(item['total_eggs']);
          }
        }
        return categoryGroups.values.toList();

      case "eggs_sold_today":
        final list = (dashboardData!['today_sales_breakdown'] as List? ?? []);
        for (var item in list) {
          if (_matchesFilter(item['branch_name']?.toString(), null)) {
            final cat = item['category']?.toString() ?? "N/A";
            categoryGroups.putIfAbsent(
              cat,
              () => {'category': cat, 'total_eggs': 0.0, 'total_amount': 0.0},
            );
            categoryGroups[cat]!['total_eggs'] =
                categoryGroups[cat]!['total_eggs'] +
                _toNumber(item['total_eggs']);
            categoryGroups[cat]!['total_amount'] =
                categoryGroups[cat]!['total_amount'] +
                _toNumber(item['total_amount']);
          }
        }
        return categoryGroups.values.toList();

      default:
        return [];
    }
  }

  Map<String, dynamic> _getModalTitleAndHeaders(String activeCard) {
    switch (activeCard) {
      case "revenue":
        return {
          'title': "Total Revenue Breakdown (by Category)",
          'headers': ["Category", "Sold Quantity", "Amount"],
        };
      case "stock_value":
        return {
          'title': "Total Stock Value (by Category)",
          'headers': ["Category", "Total Eggs", "Value"],
        };
      case "incoming":
        return {
          'title': "Incoming Stock (by Category)",
          'headers': ["Category", "Total Eggs"],
        };
      case "damaged":
        return {
          'title': "Total Damaged Eggs (by Category)",
          'headers': ["Category", "Total Eggs"],
        };
      case "purchase":
        return {
          'title': "Total Purchase Breakdown",
          'headers': ["PO", "Supplier", "Date", "Eggs", "Amount", "Status"],
        };
      case "revenue_today":
        return {
          'title': "Today's Revenue Detailed Invoices",
          'headers': [
            "Invoice ID",
            "Branch/Customer",
            "Payment Method",
            "Eggs Sold",
            "Amount",
            "Date & Time",
          ],
        };
      case "stock_eggs":
        return {
          'title': "Total Stock Eggs (by Category)",
          'headers': ["Category", "Total Eggs"],
        };
      case "eggs_sold_today":
        return {
          'title': "Today's Eggs Sold Breakdown",
          'headers': ["Category", "Total Eggs", "Amount"],
        };
      default:
        return {'title': "Metrics Breakdown", 'headers': []};
    }
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg;
    Color text;
    if (s == 'received') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
    } else if (s == 'pending') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
    } else {
      bg = const Color(0xFFEFF6FF);
      text = const Color(0xFF1D4ED8);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  void _openDetailsModal(String activeCard) {
    int modalPage = 1;
    final int itemsPerPage = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final modalInfo = _getModalTitleAndHeaders(activeCard);
            final title = modalInfo['title'] as String;
            final headers = modalInfo['headers'] as List<String>;
            final modalData = _getModalData(activeCard);
            final int totalPages = (modalData.length / itemsPerPage).ceil() == 0
                ? 1
                : (modalData.length / itemsPerPage).ceil();

            final startIndex = (modalPage - 1) * itemsPerPage;
            final endIndex = (startIndex + itemsPerPage) > modalData.length
                ? modalData.length
                : (startIndex + itemsPerPage);
            final paginatedData = modalData.isNotEmpty
                ? modalData.sublist(startIndex, endIndex)
                : [];

            // Calculate Grand Totals based on current card
            double grandTotalEggs = 0;
            double grandTotalAmount = 0;
            if (activeCard == "revenue" || activeCard == "eggs_sold_today") {
              grandTotalEggs = modalData.fold(
                0.0,
                (sum, item) => sum + _toNumber(item['total_eggs']),
              );
              grandTotalAmount = modalData.fold(
                0.0,
                (sum, item) => sum + _toNumber(item['total_amount']),
              );
            } else if (activeCard == "stock_value") {
              grandTotalEggs = modalData.fold(
                0.0,
                (sum, item) => sum + _toNumber(item['total_eggs']),
              );
              grandTotalAmount = modalData.fold(
                0.0,
                (sum, item) => sum + _toNumber(item['total_value']),
              );
            } else if (activeCard == "incoming" ||
                activeCard == "damaged" ||
                activeCard == "stock_eggs") {
              grandTotalEggs = modalData.fold(
                0.0,
                (sum, item) => sum + _toNumber(item['total_eggs']),
              );
            } else if (activeCard == "purchase") {
              grandTotalEggs = modalData.fold(
                0.0,
                (sum, item) => sum + _toNumber(item['total_eggs']),
              );
              grandTotalAmount = modalData.fold(
                0.0,
                (sum, item) => sum + _toNumber(item['revenue']),
              );
            } else if (activeCard == "revenue_today") {
              grandTotalEggs = modalData.fold(
                0.0,
                (sum, item) => sum + _toNumber(item['total_eggs_sold']),
              );
              grandTotalAmount = modalData.fold(
                0.0,
                (sum, item) => sum + _toNumber(item['total_amount']),
              );
            }

            final branches = (dashboardData?['branches'] as List? ?? []);

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        // Dropdown Filter inside modal
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            underline: const SizedBox(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedFilter = val;
                                });
                                setStateModal(() {
                                  modalPage = 1;
                                });
                              }
                            },
                            items: [
                              const DropdownMenuItem(
                                value: "All Branches",
                                child: Text("All Branches"),
                              ),
                              const DropdownMenuItem(
                                value: "Warehouse",
                                child: Text("Warehouse"),
                              ),
                              ...branches.map(
                                (b) => DropdownMenuItem(
                                  value: b['branch_name']?.toString() ?? '',
                                  child: Text(
                                    b['branch_name']?.toString() ?? '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Modal Content Table
                    Expanded(
                      child: modalData.isEmpty
                          ? const Center(
                              child: Text(
                                "No detailed data available for this branch yet.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  Table(
                                    columnWidths: activeCard == "purchase"
                                        ? const {
                                            0: FlexColumnWidth(1.2),
                                            1: FlexColumnWidth(1.5),
                                            2: FlexColumnWidth(1.8),
                                            3: FlexColumnWidth(1.0),
                                            4: FlexColumnWidth(1.2),
                                            5: FlexColumnWidth(1.2),
                                          }
                                        : activeCard == "revenue_today"
                                        ? const {
                                            0: FlexColumnWidth(1.0),
                                            1: FlexColumnWidth(2.0),
                                            2: FlexColumnWidth(1.5),
                                            3: FlexColumnWidth(1.0),
                                            4: FlexColumnWidth(1.2),
                                            5: FlexColumnWidth(2.2),
                                          }
                                        : null,
                                    border: TableBorder(
                                      horizontalInside: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    children: [
                                      // Header Row
                                      TableRow(
                                        children: headers.map((h) {
                                          final isRightAlign =
                                              h == "Amount" ||
                                              h == "Value" ||
                                              (h == "Total Eggs" &&
                                                  activeCard == "damaged");
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              h,
                                              textAlign: isRightAlign
                                                  ? TextAlign.right
                                                  : h == "Status"
                                                  ? TextAlign.center
                                                  : TextAlign.left,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      // Body Rows
                                      ...paginatedData.map((item) {
                                        return TableRow(
                                          children: _buildTableRowCells(
                                            activeCard,
                                            item,
                                          ),
                                        );
                                      }).toList(),
                                      // Grand Total Footer Row
                                      TableRow(
                                        children: _buildTableFooterCells(
                                          activeCard,
                                          grandTotalEggs,
                                          grandTotalAmount,
                                          headers.length,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),

                    // Pagination Control
                    if (totalPages > 1) ...[
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          "Page $modalPage of $totalPages (${modalData.length} records)",
          style: TextStyle(
            fontSize: getWidth(context, 12),
            color: Colors.grey,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),

      SizedBox(width: getWidth(context, 8)),

      Row(
        children: [
          SizedBox(
            height: getHeight(context, 36),
            child: OutlinedButton(
              onPressed: modalPage == 1
                  ? null
                  : () {
                      setStateModal(() {
                        modalPage = modalPage - 1;
                      });
                    },
              child: Text(
                "Previous",
                style: TextStyle(
                  fontSize: getWidth(context, 12),
                ),
              ),
            ),
          ),

          SizedBox(width: getWidth(context, 8)),

          SizedBox(
            height: getHeight(context, 36),
            child: OutlinedButton(
              onPressed: modalPage == totalPages
                  ? null
                  : () {
                      setStateModal(() {
                        modalPage = modalPage + 1;
                      });
                    },
              child: Text(
                "Next",
                style: TextStyle(
                  fontSize: getWidth(context, 12),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  ),

  SizedBox(height: getHeight(context, 12)),
],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildTableRowCells(String activeCard, dynamic item) {
    switch (activeCard) {
      case "revenue":
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item['category']?.toString() ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatNumber(_toNumber(item['total_eggs'])),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatCurrency(_toNumber(item['total_amount'])),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ];
      case "stock_value":
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item['category']?.toString() ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatNumber(_toNumber(item['total_eggs'])),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatCurrency(_toNumber(item['total_value'])),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ];
      case "incoming":
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item['category']?.toString() ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "${formatNumber(_toNumber(item['total_eggs']))} Eggs",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ];
      case "damaged":
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item['category']?.toString() ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "${formatNumber(_toNumber(item['total_eggs']))} Eggs",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ];
      case "purchase":
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item['category']?.toString() ?? "N/A",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF7C3AED),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item['branch_name']?.toString() ?? "N/A",
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item['date']?.toString() ?? "N/A",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatNumber(_toNumber(item['total_eggs'])),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatCurrency(_toNumber(item['revenue'])),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: _buildStatusBadge(item['status']?.toString() ?? "N/A"),
            ),
          ),
        ];
      case "revenue_today":
        final branchLabel = item['branch_name'] == 'Warehouse'
            ? "${item['customer_name'] ?? 'Walk-in'} (Warehouse)"
            : (item['branch_name']?.toString() ?? "N/A");
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "#${item['id']}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF0B74FF),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(branchLabel, style: const TextStyle(fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              (item['payment_method']?.toString() ?? "CASH").toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatNumber(_toNumber(item['total_eggs_sold'])),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatCurrency(_toNumber(item['total_amount'])),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatDate(item['created_at']),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ];
      case "stock_eggs":
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item['category']?.toString() ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "${formatNumber(_toNumber(item['total_eggs']))} Eggs",
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ];
      case "eggs_sold_today":
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item['category']?.toString() ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatNumber(_toNumber(item['total_eggs'])),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              formatCurrency(_toNumber(item['total_amount'])),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  List<Widget> _buildTableFooterCells(
    String activeCard,
    double grandTotalEggs,
    double grandTotalAmount,
    int colCount,
  ) {
    final borderTop = const BorderSide(color: Color(0xFFE5E7EB), width: 2);
    final textStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.black,
    );

    List<Widget> cells = List.generate(colCount, (_) => const SizedBox());

    switch (activeCard) {
      case "revenue":
      case "eggs_sold_today":
        cells[0] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text("Grand Total", style: textStyle),
        );
        cells[1] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text("${formatNumber(grandTotalEggs)} Eggs", style: textStyle),
        );
        cells[2] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text(
            formatCurrency(grandTotalAmount),
            textAlign: TextAlign.right,
            style: textStyle,
          ),
        );
        break;
      case "stock_value":
        cells[0] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text("Grand Total", style: textStyle),
        );
        cells[1] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text("${formatNumber(grandTotalEggs)} Eggs", style: textStyle),
        );
        cells[2] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text(
            formatCurrency(grandTotalAmount),
            textAlign: TextAlign.right,
            style: textStyle,
          ),
        );
        break;
      case "incoming":
      case "stock_eggs":
        cells[0] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text("Grand Total", style: textStyle),
        );
        cells[1] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text(
            "${formatNumber(grandTotalEggs)} Eggs",
            textAlign: TextAlign.right,
            style: textStyle,
          ),
        );
        break;
      case "damaged":
        cells[0] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text("Grand Total", style: textStyle),
        );
        cells[1] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text(
            "${formatNumber(grandTotalEggs)} Eggs",
            textAlign: TextAlign.right,
            style: textStyle.copyWith(color: const Color(0xFFEF4444)),
          ),
        );
        break;
      case "purchase":
        cells[0] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text("Grand Total", style: textStyle),
        );
        cells[3] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text(
            formatNumber(grandTotalEggs),
            textAlign: TextAlign.right,
            style: textStyle,
          ),
        );
        cells[4] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text(
            formatCurrency(grandTotalAmount),
            textAlign: TextAlign.right,
            style: textStyle,
          ),
        );
        break;
      case "revenue_today":
        cells[0] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text("Grand Total", style: textStyle),
        );
        cells[3] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text(formatNumber(grandTotalEggs), style: textStyle),
        );
        cells[4] = Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(top: borderTop)),
          child: Text(
            formatCurrency(grandTotalAmount),
            textAlign: TextAlign.right,
            style: textStyle,
          ),
        );
        break;
    }
    return cells;
  }

  void _openAllActivitiesModal(List<dynamic> activities) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Activities",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: activities.isEmpty
                    ? const Center(child: Text("No recent activities."))
                    : ListView.separated(
                        itemCount: activities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final item = activities[idx];
                          final name = item['movement_type'] ?? "System";
                          final action =
                              "${item['tray_id']} moved from ${item['from_location'] ?? 'N/A'} to ${item['to_location'] ?? 'N/A'}.";
                          final timeStr = formatTimeAgo(item['created_at']);
                          final status = item['status'] ?? "Movement";

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue.shade50,
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : "S",
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "$name ",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: action),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$timeStr • $status",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: AdminDashboardSkeletonLoader()),
      );
    }

    // Dynamic Metrics derived from raw lists under dashboardData
    final totalRevenue = (dashboardData?['sales_all_breakdown'] as List? ?? [])
        .where((item) => _matchesFilter(item['branch_name']?.toString(), null))
        .fold(0.0, (sum, item) => sum + _toNumber(item['total_amount']));

    final totalStockValue = (dashboardData?['inventory'] as List? ?? [])
        .where((item) => _matchesFilter(null, item['location']?.toString()))
        .fold(0.0, (sum, item) => sum + _toNumber(item['total_value']));

    final incomingStockEggs = (dashboardData?['incoming'] as List? ?? [])
        .where((item) => _matchesFilter(null, item['destination']?.toString()))
        .fold(0.0, (sum, item) => sum + _toNumber(item['total_eggs']));

    final totalDamagedEggs = (dashboardData?['damaged'] as List? ?? [])
        .where((item) => _matchesFilter(null, item['location']?.toString()))
        .fold(0.0, (sum, item) => sum + _toNumber(item['total_eggs']));

    final totalPurchaseAmount =
        (selectedFilter == "Warehouse" || selectedFilter == "All Branches")
        ? (dashboardData?['purchase_breakdown'] as List? ?? []).fold(
            0.0,
            (sum, item) => sum + _toNumber(item['revenue']),
          )
        : 0.0;

    final totalRevenueToday = (dashboardData?['sales_today'] as List? ?? [])
        .where((item) => _matchesFilter(item['branch_name']?.toString(), null))
        .fold(0.0, (sum, item) => sum + _toNumber(item['total_amount']));

    final totalStockEggs = (dashboardData?['inventory'] as List? ?? [])
        .where((item) => _matchesFilter(null, item['location']?.toString()))
        .fold(0.0, (sum, item) => sum + _toNumber(item['total_eggs']));

    final totalEggsSoldToday = (dashboardData?['sales_today'] as List? ?? [])
        .where((item) => _matchesFilter(item['branch_name']?.toString(), null))
        .fold(0.0, (sum, item) => sum + _toNumber(item['total_eggs_sold']));

    final profit = _toNumber(dashboardData?['profit']);

    // Prep dynamic alerts list
    final alerts = <Map<String, dynamic>>[];
    if (totalStockEggs < 1000 && totalStockEggs > 0) {
      alerts.add({
        "type": "critical",
        "title": "Critical Stock Depletion",
        "description":
            "Total stock is at ${formatNumber(totalStockEggs)} eggs. Monitor replenishment for branch demand.",
        "action": "Review & Reorder",
        "icon": Icons.warning_amber_rounded,
        "page": const Newpurchase(),
      });
    }
    if (incomingStockEggs > 0) {
      alerts.add({
        "type": "warning",
        "title": "Incoming Stock In Transit",
        "description":
            "${formatNumber(incomingStockEggs)} eggs are currently in transit and need tracking till warehouse receipt.",
        "action": "Track Shipment",
        "icon": Icons.access_time_rounded,
        "page": const IncomingStock(),
      });
    }
    if (profit < 0) {
      alerts.add({
        "type": "warning",
        "title": "Profit Margin Alert",
        "description":
            "Estimated profit is currently negative (${formatCurrency(profit)}). Review pricing and expenses.",
        "action": "View Financials",
        "icon": Icons.error_outline_rounded,
        "page": const AdminReportDashboardScreen(),
      });
    }

    final activities = dashboardData?['recent_activity'] as List? ?? [];
    final recentActivities = activities.take(10).toList();

    final branches = (dashboardData?['branches'] as List? ?? []);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text("Dashboard Overview", style: AppTextStyles.headingText22),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
              size: 26,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome & Role Header with Global filter dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome to ERP Overview",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "Role: Warehouse & Admin",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Dropdown Filter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      underline: const SizedBox(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedFilter = val;
                          });
                        }
                      },
                      items: [
                        const DropdownMenuItem(
                          value: "All Branches",
                          child: Text("All Branches"),
                        ),
                        const DropdownMenuItem(
                          value: "Warehouse",
                          child: Text("Warehouse"),
                        ),
                        ...branches.map(
                          (b) => DropdownMenuItem(
                            value: b['branch_name']?.toString() ?? '',
                            child: Text(b['branch_name']?.toString() ?? ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Horizontal Row of Action Buttons
              _buildActionRow(context),
              const SizedBox(height: 24),

              // Dynamic Metric Cards Grid (8 Cards)
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                children: [
                  _buildMetricCard(
                    title: "Total Revenue",
                    value: formatCurrency(totalRevenue),
                    icon: Icons.account_balance_wallet_outlined,
                    color: const Color(0xFF0B74FF),
                    onTap: () => _openDetailsModal("revenue"),
                  ),
                  _buildMetricCard(
                    title: "Total Stock Value",
                    value: formatCurrency(totalStockValue),
                    icon: Icons.currency_exchange_outlined,
                    color: const Color(0xFF16A34A),
                    onTap: () => _openDetailsModal("stock_value"),
                  ),
                  _buildMetricCard(
                    title: "Incoming Stock",
                    value: "${formatNumber(incomingStockEggs)} Eggs",
                    icon: Icons.local_shipping_outlined,
                    color: const Color(0xFFF97316),
                    onTap: () => _openDetailsModal("incoming"),
                  ),
                  _buildMetricCard(
                    title: "Total Purchase",
                    value: formatCurrency(totalPurchaseAmount),
                    icon: Icons.shopping_cart_outlined,
                    color: const Color(0xFF7C3AED),
                    onTap: () => _openDetailsModal("purchase"),
                  ),
                  _buildMetricCard(
                    title: "Total Revenue (Today)",
                    value: formatCurrency(totalRevenueToday),
                    icon: Icons.storefront_outlined,
                    color: const Color(0xFFF59E0B),
                    onTap: () => _openDetailsModal("revenue_today"),
                  ),
                  _buildMetricCard(
                    title: "Total Stock Eggs",
                    value: "${formatNumber(totalStockEggs)} Eggs",
                    icon: Icons.egg_outlined,
                    color: const Color(0xFF0B74FF),
                    onTap: () => _openDetailsModal("stock_eggs"),
                  ),
                  _buildMetricCard(
                    title: "Total Eggs Sold (Today)",
                    value: "${formatNumber(totalEggsSoldToday)} Eggs",
                    icon: Icons.egg_rounded,
                    color: const Color(0xFF16A34A),
                    onTap: () => _openDetailsModal("eggs_sold_today"),
                  ),
                  _buildMetricCard(
                    title: "Damaged Eggs",
                    value: "${formatNumber(totalDamagedEggs)} Eggs",
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: () => _openDetailsModal("damaged"),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Activities & Actions Required Dual Widgets
              _buildPanelsSection(recentActivities, activities, alerts),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionButton(
            context: context,
            label: "Create\nPurchase Order",
            icon: Icons.add_circle_outline,
            targetPage: const Newpurchase(),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            label: "Dispatch\nItems",
            icon: Icons.local_shipping_outlined,
            targetPage: const DispatchPlanningPage(),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            label: "New Sales\nEntry",
            icon: Icons.receipt_long_outlined,
            targetPage: const SalesEntryPage(),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            label: "Export\nReport",
            icon: Icons.exit_to_app_rounded,
            targetPage: const AdminReportDashboardScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Widget targetPage,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 115,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const Row(
              children: [
                Text(
                  "Tap to view breakdown",
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 8, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelsSection(
    List<dynamic> recentActivities,
    List<dynamic> activities,
    List<Map<String, dynamic>> alerts,
  ) {
    return Column(
      children: [
        // Recent Activity Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Activity",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openAllActivitiesModal(activities),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      "View All",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentActivities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      "No recent activity.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentActivities.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, idx) {
                    final item = recentActivities[idx];
                    final name = item['movement_type'] ?? "System";
                    final action =
                        "${item['tray_id']} moved from ${item['from_location'] ?? 'N/A'} to ${item['to_location'] ?? 'N/A'}.";
                    final timeStr = formatTimeAgo(item['created_at']);
                    final category = item['status'] ?? "Movement";

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "S",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "$name ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: action),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$timeStr • $category",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Required Card (Alerts)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Action Required",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: alerts.isEmpty
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${alerts.length} Alerts",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: alerts.isEmpty ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (alerts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 36,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Everything is fine!",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "No urgent actions required at this moment.",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: alerts.map((alert) {
                    final isCritical = alert['type'] == 'critical';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCritical
                            ? Colors.red.shade50
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCritical
                              ? Colors.red.shade100
                              : Colors.amber.shade200,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            alert['icon'] as IconData,
                            size: 20,
                            color: isCritical
                                ? Colors.red
                                : Colors.amber.shade800,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert['title'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isCritical
                                        ? Colors.red.shade900
                                        : Colors.amber.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  alert['description'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCritical
                                        ? Colors.red.shade700
                                        : Colors.amber.shade800,
                                  ),
                                ),
                                if (alert['page'] != null) ...[
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              alert['page'] as Widget,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          alert['action'] as String,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 10,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
