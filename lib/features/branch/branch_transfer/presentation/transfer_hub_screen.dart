import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/transfer_hub_bloc.dart';
import '../bloc/transfer_hub_event.dart';
import '../bloc/transfer_hub_state.dart';
import '../data/datasource/branch_transfer_remote_datasource.dart';
import 'branch_transfer_screen.dart';

class TransferHubScreen extends StatelessWidget {
  const TransferHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferHubBloc(
        datasource: BranchTransferRemoteDatasource(),
      ),
      child: const TransferHubView(),
    );
  }
}

class TransferHubView extends StatefulWidget {
  const TransferHubView({super.key});

  @override
  State<TransferHubView> createState() => _TransferHubViewState();
}

class _TransferHubViewState extends State<TransferHubView> {
  int? branchId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    branchId = prefs.getInt('branch_id');
    if (branchId != null) {
      if (mounted) {
        context.read<TransferHubBloc>().add(LoadTransferHubEvent(branchId: branchId!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text("Stock Transfer Hub", style: AppTextStyles.headingText20),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<TransferHubBloc, TransferHubState>(
        builder: (context, state) {
          if (state is TransferHubLoading || state is TransferHubInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransferHubError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is TransferHubLoaded) {
            return _buildContent(context, state.data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final summary = data['summary'] ?? {};
    final recentOut = data['recent_transfers_out'] as List? ?? [];
    final incoming = data['incoming_transfers'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Manage incoming and outgoing branch transfers",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BranchTransferScreen()),
                );
                _loadData();
              },
              icon: const Icon(Icons.local_shipping, size: 18),
              label: const Text("Create Transfer Stock"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0ea5e9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            _buildSummaryCard(
              title: "Total Transferred Out",
              icon: Icons.trending_up,
              iconBg: const Color(0xfff0fdf4),
              iconColor: const Color(0xff16a34a),
              trays: summary['total_transferred_out_trays'] ?? 0,
              eggs: summary['total_transferred_out_eggs'] ?? 0,
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              title: "Incoming Stock (Pending)",
              icon: Icons.trending_down,
              iconBg: const Color(0xfffffbeb),
              iconColor: const Color(0xffd97706),
              trays: summary['incoming_pending_trays'] ?? 0,
              eggs: summary['incoming_pending_eggs'] ?? 0,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                // Navigate to receive stock
                Navigator.pushNamed(context, '/branch_receive_stock').then((_) => _loadData());
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xff10b981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text("Receive Incoming Stock", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Click here to accept deliveries", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text("Recent Transfers (Out)", style: AppTextStyles.headingText20),
            const SizedBox(height: 12),
            _buildRecentOutTable(recentOut),
            const SizedBox(height: 32),
            Text("Incoming Stock", style: AppTextStyles.headingText20),
            const SizedBox(height: 12),
            _buildIncomingTable(incoming),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required int trays,
    required int eggs,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                trays.toString(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
              ),
              const SizedBox(width: 4),
              Text("Trays", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 4),
          Text("$eggs Eggs", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildRecentOutTable(List recentOut) {
    if (recentOut.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text("No recent transfers found.", style: TextStyle(color: Colors.grey))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xfff8fafc)),
          columns: const [
            DataColumn(label: Text("Dispatch ID")),
            DataColumn(label: Text("To")),
            DataColumn(label: Text("Qty")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Date")),
          ],
          rows: recentOut.map((t) {
            return DataRow(cells: [
              DataCell(Text("#DS-${t['id']}", style: const TextStyle(color: Color(0xff0ea5e9), fontWeight: FontWeight.bold))),
              DataCell(Text(t['destination'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${t['total_trays']} Trays"),
                  Text("(${t['total_eggs']} eggs)", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              )),
              DataCell(_buildStatusBadge(t['status'] ?? '')),
              DataCell(Text(t['dispatch_date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(t['dispatch_date'])) : '')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIncomingTable(List incoming) {
    if (incoming.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text("No incoming stock found.", style: TextStyle(color: Colors.grey))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xfff8fafc)),
          columns: const [
            DataColumn(label: Text("Dispatch ID")),
            DataColumn(label: Text("From")),
            DataColumn(label: Text("Qty")),
            DataColumn(label: Text("Status")),
          ],
          rows: incoming.map((t) {
            return DataRow(cells: [
              DataCell(Text("#DS-${t['id']}", style: const TextStyle(color: Color(0xff0ea5e9), fontWeight: FontWeight.bold))),
              DataCell(Text(t['dispatch_source'] == 'BRANCH' ? 'Branch' : 'Warehouse', style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${t['total_trays']} Trays"),
                  Text("(${t['total_eggs']} eggs)", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              )),
              DataCell(_buildStatusBadge(t['status'] ?? '')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color textCol;

    if (status == 'DELIVERED') {
      bg = const Color(0xffdcfce7);
      textCol = const Color(0xff166534);
    } else if (status == 'PENDING_APPROVAL') {
      bg = const Color(0xfffee2e2);
      textCol = const Color(0xff991b1b);
    } else {
      bg = const Color(0xfffef9c3);
      textCol = const Color(0xff854d0e);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: textCol, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
