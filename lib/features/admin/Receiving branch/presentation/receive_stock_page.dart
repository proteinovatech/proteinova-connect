import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/bloc/receiving_branch_bloc.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/data/models/dispatch_details_model.dart';

class ReceiveStockPage extends StatelessWidget {
  final int branchId;
  final int dispatchId;

  const ReceiveStockPage({
    super.key,
    required this.branchId,
    required this.dispatchId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReceivingBranchBloc>(
      create: (context) => ReceivingBranchBloc()
        ..add(LoadDispatchDetailsEvent(branchId: branchId, dispatchId: dispatchId)),
      child: ReceiveStockBody(branchId: branchId, dispatchId: dispatchId),
    );
  }
}

class ReceiveStockBody extends StatefulWidget {
  final int branchId;
  final int dispatchId;

  const ReceiveStockBody({
    super.key,
    required this.branchId,
    required this.dispatchId,
  });

  @override
  State<ReceiveStockBody> createState() => _ReceiveStockBodyState();
}

class TrayVerifyInput {
  final String product;
  final String trayType;
  final int receivedCount;
  int damagedCount;
  String itemNotes;

  TrayVerifyInput({
    required this.product,
    required this.trayType,
    required this.receivedCount,
    this.damagedCount = 0,
    this.itemNotes = "",
  });

  int get goodCount => (receivedCount - damagedCount).clamp(0, receivedCount);
}

class _ReceiveStockBodyState extends State<ReceiveStockBody> {
  final List<TrayVerifyInput> _verificationInputs = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onConfirmReceive(BuildContext context) {
    final itemsToPost = _verificationInputs.map((input) {
      return {
        'egg_category_grade': input.product,
        'damaged_trays': input.damagedCount,
      };
    }).toList();

    context.read<ReceivingBranchBloc>().add(
          ConfirmDispatchReceiveEvent(
            branchId: widget.branchId,
            dispatchId: widget.dispatchId,
            items: itemsToPost,
            notes: _notesController.text,
          ),
        );
  }

  String _formatDate(String dateIso) {
    try {
      final date = DateTime.parse(dateIso).toLocal();
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateIso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocListener<ReceivingBranchBloc, ReceivingBranchState>(
          listener: (context, state) {
            if (state is ConfirmReceiveSuccess) {
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle_rounded, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Success"),
                    ],
                  ),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogCtx); // Close dialog
                        Navigator.pop(context); // Pop back to dashboard
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            } else if (state is ReceivingBranchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.redAccent,
                ),
              );
            }
          },
          child: BlocBuilder<ReceivingBranchBloc, ReceivingBranchState>(
            builder: (context, state) {
              DispatchDetails? details;
              bool isLoading = false;
              bool isSubmitting = false;

              if (state is DispatchDetailsLoading) {
                isLoading = true;
              } else if (state is DispatchDetailsLoaded) {
                details = state.dispatchDetails;
              } else if (state is ConfirmReceiveInProgress) {
                details = state.dispatchDetails;
                isSubmitting = true;
              } else if (state is ReceivingBranchError) {
                // Try fetching details from error context if available
              }

              // Initialize inputs once
              if (details != null && _verificationInputs.isEmpty) {
                for (var item in details.receivedItems) {
                  _verificationInputs.add(
                    TrayVerifyInput(
                      product: item.product,
                      trayType: item.trayType,
                      receivedCount: item.trays,
                    ),
                  );
                }
              }

              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber600),
                  ),
                );
              }

              if (details == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Dispatch not found or failed to load.",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Go Back"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading Info
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Receive Stock: ${details.dispatchCode}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Verify incoming stock from warehouse to update branch inventory",
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3B0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Arrived",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Grid Containers
                    _buildReceivedInfoBox(details),
                    const SizedBox(height: 16),
                    _buildReceivedItemsBox(details),
                    const SizedBox(height: 16),
                    _buildSummaryBox(details),
                    const SizedBox(height: 16),
                    _buildTrayVerificationBox(),
                    const SizedBox(height: 16),
                    _buildBranchReceivingBox(details),
                    const SizedBox(height: 16),
                    _buildFooterNotesAndActions(context, isSubmitting),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedInfoBox(DispatchDetails details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Received Info",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            children: [
              _buildDetailItem("Dispatch No.", details.dispatchCode),
              _buildDetailItem("Dispatch Date", _formatDate(details.dispatchDate)),
              _buildDetailItem("Vehicle No.", details.vehicleNumber),
              _buildDetailItem("Driver Name", details.driverName),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailItem("Branch Name", details.branchName),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
        ),
      ],
    );
  }

  Widget _buildReceivedItemsBox(DispatchDetails details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Received Items",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowHeight: 36,
              dataRowHeight: 44,
              horizontalMargin: 0,
              columns: const [
                DataColumn(
                  label: Text("Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                ),
                DataColumn(
                  label: Text("Tray Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                ),
                DataColumn(
                  label: Text("Trays", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                  numeric: true,
                ),
                DataColumn(
                  label: Text("Eggs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                  numeric: true,
                ),
              ],
              rows: [
                ...details.receivedItems.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item.product, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
                    DataCell(Text(item.trayType, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                    DataCell(Text(item.trays.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
                    DataCell(Text(item.eggs.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
                  ]);
                }),
                // Total Summary Row
                DataRow(cells: [
                  const DataCell(Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B)))),
                  const DataCell(Text("")),
                  DataCell(Text(details.totalTrays.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B)))),
                  DataCell(Text(details.totalEggs.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B)))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(DispatchDetails details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Summary",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              Icon(Icons.description_outlined, size: 18, color: Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          _buildSummaryRow("Total Trays", details.totalTrays.toString(), isBold: true),
          const SizedBox(height: 8),
          _buildSummaryRow("Total Eggs", details.totalEggs.toString(), isBold: true),
          const SizedBox(height: 8),
          _buildSummaryRow("Plastic Trays", details.plasticTrays.toString()),
          const SizedBox(height: 8),
          _buildSummaryRow("Paper Trays", details.paperTrays.toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildTrayVerificationBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tray Verification",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(110),
                1: FixedColumnWidth(80),
                2: FixedColumnWidth(70),
                3: FixedColumnWidth(70),
                4: FixedColumnWidth(70),
                5: FixedColumnWidth(120),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text("Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text("Tray Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text("Received", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text("Damaged", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text("Good", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text("Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                    ),
                  ],
                ),
                ...List.generate(_verificationInputs.length, (index) {
                  final input = _verificationInputs[index];
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(input.product, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B))),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(input.trayType, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      ),
                      // Received Field Read-Only
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(input.receivedCount.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      // Damaged input field
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: SizedBox(
                          height: 32,
                          child: TextFormField(
                            initialValue: input.damagedCount.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (val) {
                              final count = int.tryParse(val) ?? 0;
                              setState(() {
                                input.damagedCount = count.clamp(0, input.receivedCount);
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                            ),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                          ),
                        ),
                      ),
                      // Good read-only auto calculated count
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(input.goodCount.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                        ),
                      ),
                      // Notes field
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: SizedBox(
                          height: 32,
                          child: TextFormField(
                            initialValue: input.itemNotes,
                            onChanged: (val) {
                              input.itemNotes = val;
                            },
                            decoration: InputDecoration(
                              hintText: "Add notes...",
                              hintStyle: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                            ),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.error_outline_rounded, size: 14, color: Color(0xFFEF4444)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Damaged trays will be removed from your usable inventory.",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranchReceivingBox(DispatchDetails details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Branch Receiving",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          _buildSummaryRow("Branch Name", details.branchName, isBold: true),
          const SizedBox(height: 8),
          _buildSummaryRow("Logistics", details.vehicleNumber),
          const SizedBox(height: 8),
          _buildSummaryRow("Dispatch Ref", details.dispatchCode),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Action Required",
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              Text(
                "Verify & Receive",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNotesAndActions(BuildContext context, bool isSubmitting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Receiving Notes",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Enter any additional observations about this delivery...",
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
          ),
        ),
        const SizedBox(height: 20),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 45,
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : () => _onConfirmReceive(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSubmitting)
                        const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      else
                        const Icon(Icons.verified_user_outlined, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        isSubmitting ? "Processing..." : "Confirm Receive",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
