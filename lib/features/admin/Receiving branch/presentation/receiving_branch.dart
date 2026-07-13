import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/bloc/receiving_branch_bloc.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/data/models/incoming_dispatch_model.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/data/models/receiving_dashboard_model.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/presentation/receive_stock_page.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/receiving_dashboard_shimmer.dart';

class ReceivingBranchDashboardPage extends StatelessWidget {
  const ReceivingBranchDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReceivingBranchBloc>(
      create: (context) => ReceivingBranchBloc()..add(FetchBranchesListEvent()),
      child: const ReceivingBranchDashboardBody(),
    );
  }
}

class ReceivingBranchDashboardBody extends StatefulWidget {
  const ReceivingBranchDashboardBody({super.key});

  @override
  State<ReceivingBranchDashboardBody> createState() => _ReceivingBranchDashboardBodyState();
}

class _ReceivingBranchDashboardBodyState extends State<ReceivingBranchDashboardBody> {
  int? _selectedBranchId;

  void _onBranchChanged(int branchId, BuildContext context) {
    setState(() {
      _selectedBranchId = branchId;
    });
    context.read<ReceivingBranchBloc>().add(SelectBranchEvent(branchId));
  }

  void _showFilteredShipmentsModal(
    BuildContext context,
    String title,
    String filterType,
    List<IncomingDispatch> shipments,
    int branchId,
  ) {
    final filtered = shipments.where((s) {
      final statusUpper = s.status.toUpperCase();
      switch (filterType) {
        case 'expected':
          return statusUpper == 'EXPECTED_TODAY';
        case 'ready':
          return statusUpper == 'ARRIVAL';
        case 'delayed':
          return statusUpper == 'DELAYED';
        case 'all':
        default:
          return true;
      }
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          "No records found for this category.",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 20),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildDispatchItemRow(item, branchId, context, sourceModalContext: modalContext);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDispatchItemRow(
    IncomingDispatch item,
    int branchId,
    BuildContext blocContext, {
    BuildContext? sourceModalContext,
  }) {
    final statusUpper = item.status.toUpperCase();
    final bool canMarkArrival = statusUpper == 'IN_TRANSIT' ||
        statusUpper == 'EXPECTED_TODAY' ||
        statusUpper == 'DELAYED';
    final bool canReceive = statusUpper == 'ARRIVAL';

    String arrivalDateStr = item.expectedArrival;
    try {
      final parsed = DateTime.parse(item.expectedArrival).toLocal();
      arrivalDateStr = DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.dispatchCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              _buildStatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.vehicleDriver,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Expected: $arrivalDateStr",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${item.totalTrays} Trays",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${item.totalEggs} Eggs",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (canMarkArrival)
                ElevatedButton(
                  onPressed: () {
                    if (sourceModalContext != null) {
                      Navigator.pop(sourceModalContext);
                    }
                    blocContext.read<ReceivingBranchBloc>().add(
                          TriggerMarkArrivalEvent(branchId: branchId, dispatchId: item.dispatchId),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    "Mark Arrival",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              else if (canReceive)
                ElevatedButton(
                  onPressed: () {
                    if (sourceModalContext != null) {
                      Navigator.pop(sourceModalContext);
                    }
                    Navigator.push(
                      blocContext,
                      MaterialPageRoute(
                        builder: (_) => ReceiveStockPage(
                          branchId: branchId,
                          dispatchId: item.dispatchId,
                        ),
                      ),
                    ).then((_) {
                      blocContext.read<ReceivingBranchBloc>().add(SelectBranchEvent(branchId));
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    "Receive Stock",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Text(
                  statusUpper.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toUpperCase();
    Color bg;
    Color text;

    switch (s) {
      case "EXPECTED_TODAY":
        bg = const Color(0xFFFFEAD2);
        text = const Color(0xFFD97706);
        break;
      case "DELAYED":
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFEF4444);
        break;
      case "IN_TRANSIT":
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0284C7);
        break;
      case "ARRIVAL":
        bg = const Color(0xFFF3E8FF);
        text = const Color(0xFF9333EA);
        break;
      case "RECEIVED":
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF10B981);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        s.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<ReceivingBranchBloc, ReceivingBranchState>(
          builder: (context, state) {
            List<BranchModel> branches = [];
            int selectedBranchId = 0;
            ReceivingDashboardData? dashboardData;
            bool isLoading = false;
            // ignore: unused_local_variable
            int? loadingMarkId;

            if (state is ReceivingBranchLoading) {
              isLoading = true;
            } else if (state is ReceivingBranchDashboardLoaded) {
              branches = state.branches;
              selectedBranchId = state.selectedBranchId;
              dashboardData = state.dashboardData;
            } else if (state is MarkArrivalInProgress) {
              branches = state.branches;
              selectedBranchId = state.selectedBranchId;
              dashboardData = state.dashboardData;
              loadingMarkId = state.actionDispatchId;
            } else if (state is DispatchDetailsLoading) {
              branches = state.branches;
              selectedBranchId = state.selectedBranchId;
              dashboardData = state.dashboardData;
            } else if (state is DispatchDetailsLoaded) {
              branches = state.branches;
              selectedBranchId = state.selectedBranchId;
              dashboardData = state.dashboardData;
            } else if (state is ReceivingBranchError) {
              branches = state.branches;
              selectedBranchId = state.selectedBranchId ?? 0;
              dashboardData = state.dashboardData;
            }

            if (_selectedBranchId != null) {
              selectedBranchId = _selectedBranchId!;
            } else if (selectedBranchId != 0) {
              _selectedBranchId = selectedBranchId;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header Dropdown & Notification
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          "Distribution Dashboard",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Branch Selection Dropdown
                      if (branches.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: branches.any((b) => b.id == selectedBranchId) ? selectedBranchId : branches[0].id,
                              onChanged: (id) {
                                if (id != null) _onBranchChanged(id, context);
                              },
                              items: branches.map((b) {
                                return DropdownMenuItem<int>(
                                  value: b.id,
                                  child: Text(
                                    b.branchName,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Yellow Receiving button indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3B0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.local_shipping_outlined, size: 16, color: Colors.black),
                        SizedBox(width: 6),
                        Text(
                          "Receiving",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Loader / Error Overlay
                if (isLoading)
                  const Expanded(
                    child: ReceivingDashboardShimmer(),
                  )
                else if (state is ReceivingBranchError && dashboardData == null)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else if (dashboardData != null) ...[
                  // Cards Metrics Grid
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        _buildMetricCard(
                          title: "Expected Today",
                          value: dashboardData.expectedToday.toString(),
                          icon: Icons.local_shipping_outlined,
                          onTap: () => _showFilteredShipmentsModal(
                            context,
                            "Expected Today Shipments",
                            "expected",
                            dashboardData!.shipments,
                            selectedBranchId,
                          ),
                        ),
                        _buildMetricCard(
                          title: "Ready for Unloading",
                          value: dashboardData.readyForUnloading.toString(),
                          icon: Icons.send_rounded,
                          onTap: () => _showFilteredShipmentsModal(
                            context,
                            "Ready for Unloading",
                            "ready",
                            dashboardData!.shipments,
                            selectedBranchId,
                          ),
                        ),
                        _buildMetricCard(
                          title: "Delayed",
                          value: dashboardData.delayedInTransit.toString(),
                          icon: Icons.calendar_today_outlined,
                          onTap: () => _showFilteredShipmentsModal(
                            context,
                            "Delayed Shipments",
                            "delayed",
                            dashboardData!.shipments,
                            selectedBranchId,
                          ),
                        ),
                        _buildMetricCard(
                          title: "Total Transit",
                          value: "${dashboardData.totalShipments}\nShipments",
                          icon: Icons.unarchive_outlined,
                          isWrapValue: true,
                          onTap: () => _showFilteredShipmentsModal(
                            context,
                            "Total Shipments in Transit",
                            "all",
                            dashboardData!.shipments,
                            selectedBranchId,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Incoming dispatches List
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Incoming Dispatches",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: dashboardData.shipments.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No incoming dispatches found.",
                                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: dashboardData.shipments.length,
                                    separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                    itemBuilder: (context, index) {
                                      final item = dashboardData!.shipments[index];
                                      return _buildDispatchItemRow(
                                        item,
                                        selectedBranchId,
                                        context,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool isWrapValue = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                Icon(icon, size: 18, color: const Color(0xFF64748B)),
              ],
            ),
            const Spacer(),
            if (isWrapValue)
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value.split('\n')[0],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: value.split('\n')[1],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
