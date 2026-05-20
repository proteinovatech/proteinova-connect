import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import '../bloc/daily_closing_admin_bloc.dart';
import '../bloc/daily_closing_admin_event.dart';
import '../bloc/daily_closing_admin_state.dart';
import '../data/daily_closing_admin_service.dart';
import '../model/branch_selector_model.dart';
import '../model/daily_closing_admin_model.dart';

class DailyClosingScreen extends StatelessWidget {
  const DailyClosingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DailyClosingAdminBloc(DailyClosingAdminService())..add(LoadBranchesEvent()),
      child: const DailyClosingView(),
    );
  }
}

class DailyClosingView extends StatefulWidget {
  const DailyClosingView({super.key});

  @override
  State<DailyClosingView> createState() => _DailyClosingViewState();
}

class _DailyClosingViewState extends State<DailyClosingView> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _countedCashController = TextEditingController();
  
  Map<String, bool> checklist = {
    'sales': false,
    'cash': false,
    'stock': false,
  };

  @override
  void dispose() {
    _notesController.dispose();
    _countedCashController.dispose();
    super.dispose();
  }

  bool get isChecklistComplete =>
      checklist['sales']! && checklist['cash']! && checklist['stock']!;

  void _toggleChecklist(String key, String status) {
    if (status == "CLOSED") return;
    setState(() {
      checklist[key] = !checklist[key]!;
    });
  }

  String formatCurrency(num val) {
    return "₹${val.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DailyClosingAdminBloc, DailyClosingAdminState>(
      listener: (context, state) {
        if (state.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? "Saved successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        // Auto-initialize controllers on load
        if (state.dashboardData != null) {
          _notesController.text = state.dashboardData!.notes;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background1,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Text("Daily Closing", style: AppTextStyles.headingText22),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, size: 14, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    "Admin",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: BlocBuilder<DailyClosingAdminBloc, DailyClosingAdminState>(
          builder: (context, state) {
            if (state.isBranchesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.branches.isEmpty) {
              return const Center(child: Text("No branches found."));
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (state.selectedBranchId != null) {
                  context.read<DailyClosingAdminBloc>().add(
                    SelectBranchEvent(state.selectedBranchId!),
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action & Branch Selector Bar
                    _buildActionBar(context, state),
                    const SizedBox(height: 16),

                    if (state.isDashboardLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.dashboardData == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60.0),
                        child: Center(child: Text("Please select a branch to load dashboard details.")),
                      )
                    else ...[
                      // Stock Summary Card
                      _buildStockSummary(state.dashboardData!),
                      const SizedBox(height: 16),

                      // Cash Summary Card
                      _buildCashSummary(state.dashboardData!),
                      const SizedBox(height: 16),

                      // Online Transaction Summary Card
                      _buildOnlineSummary(state.dashboardData!),
                      const SizedBox(height: 16),

                      // Sales & Expenses Dual Cards
                      _buildSalesExpenseSummary(state.dashboardData!),
                      const SizedBox(height: 16),

                      // Closing Stock Value Estimated Card
                      _buildClosingStockValue(state.dashboardData!),
                      const SizedBox(height: 16),

                      // Notes & Checklist Interactive Section
                      _buildNotesChecklist(state.dashboardData!),
                      const SizedBox(height: 24),

                      // Bottom actions
                      _buildFooterActions(context, state),
                      const SizedBox(height: 40),
                    ]
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, DailyClosingAdminState state) {
    final _ = state.branches.firstWhere(
      (b) => b.id == state.selectedBranchId,
      orElse: () => state.branches.first,
    );

    final status = state.dashboardData?.status ?? "OPEN";
    final isClosed = status == "CLOSED";

    return Container(
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
            children: [
              const Icon(Icons.store, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              const Text(
                "Select Branch",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          DropdownButtonFormField<int>(
            value: state.selectedBranchId,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: state.branches.map((BranchSelectorModel branch) {
              return DropdownMenuItem<int>(
                value: branch.id,
                child: Text(
                  branch.branchName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            onChanged: (int? value) {
              if (value != null) {
                context.read<DailyClosingAdminBloc>().add(SelectBranchEvent(value));
              }
            },
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isClosed ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Status: $status",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isClosed ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  // Admin History placeholder action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("History screen placeholder")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("History", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Verify all details before closing the day. Once closed, entries cannot be edited.",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSummary(DailyClosingAdminModel data) {
    return _buildCard(
      title: "Stock Summary",
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade50),
            children: const [
              Padding(padding: EdgeInsets.all(8), child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              Padding(padding: EdgeInsets.all(8), child: Text("Opening", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              Padding(padding: EdgeInsets.all(8), child: Text("Received", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              Padding(padding: EdgeInsets.all(8), child: Text("Sold", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              Padding(padding: EdgeInsets.all(8), child: Text("Closing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
            ],
          ),
          TableRow(
            children: [
              const Padding(padding: EdgeInsets.all(8), child: Text("Total Trays", style: TextStyle(fontSize: 12))),
              Padding(padding: const EdgeInsets.all(8), child: Text(data.openingTrays.toString(), style: const TextStyle(fontSize: 12))),
              Padding(padding: const EdgeInsets.all(8), child: Text(data.receivedTrays.toString(), style: const TextStyle(fontSize: 12))),
              Padding(padding: const EdgeInsets.all(8), child: Text(data.soldTrays.toString(), style: const TextStyle(fontSize: 12))),
              Padding(padding: const EdgeInsets.all(8), child: Text(data.closingTrays.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade50),
            children: [
              const Padding(padding: EdgeInsets.all(8), child: Text("Total Eggs", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text("Est. from trays", style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(),
              const SizedBox(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text((data.closingTrays * 30).toStringAsFixed(0), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashSummary(DailyClosingAdminModel data) {
    final systemExpectedCash = data.sales.cash - (data.expenses.cash);
    final countedCash = double.tryParse(_countedCashController.text) ?? 0.0;
    final diff = countedCash - systemExpectedCash;

    final isClosed = data.status == "CLOSED";

    return _buildCard(
      title: "Cash Summary",
      child: Column(
        children: [
          _buildRowItem("Opening Cash", formatCurrency(0)),
          _buildRowItem("Cash Sales", formatCurrency(data.sales.cash)),
          _buildRowItem("Expenses (Cash)", "-${formatCurrency(data.expenses.cash)}", textColor: Colors.red),
          const Divider(),
          _buildRowItem("Closing Cash (Expected)", formatCurrency(systemExpectedCash), isBold: true),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Closing Cash (Counted)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              SizedBox(
                width: 130,
                height: 36,
                child: TextField(
                  controller: _countedCashController,
                  keyboardType: TextInputType.number,
                  enabled: !isClosed,
                  textAlign: TextAlign.right,
                  onChanged: (_) {
                    setState(() {});
                  },
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    filled: isClosed,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          _buildRowItem(
            "Difference",
            formatCurrency(diff),
            isBold: true,
            textColor: diff == 0 ? Colors.green : (diff < 0 ? Colors.red : Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineSummary(DailyClosingAdminModel data) {
    return _buildCard(
      title: "Online Transaction Summary",
      child: Column(
        children: [
          _buildRowItem("UPI Sales", formatCurrency(data.sales.upi)),
          _buildRowItem("Card Sales", formatCurrency(data.sales.card)),
          const Divider(),
          _buildRowItem("Total Online", formatCurrency(data.sales.upi + data.sales.card), isBold: true),
          _buildRowItem("Total Collection", formatCurrency(data.sales.total), isBold: true, textColor: Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildSalesExpenseSummary(DailyClosingAdminModel data) {
    return Column(
      children: [
        _buildCard(
          title: "Sales Summary",
          child: Row(
            children: [
              Expanded(child: _buildGridBox("Total Sales", data.sales.total, Colors.indigo)),
              const SizedBox(width: 8),
              Expanded(child: _buildGridBox("Cash Sales", data.sales.cash, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildGridBox("Online Sales", data.sales.upi + data.sales.card, Colors.blue)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: "Expense Summary",
          child: Row(
            children: [
              Expanded(child: _buildGridBox("Total Expenses", data.expenses.total, Colors.red)),
              const SizedBox(width: 8),
              Expanded(child: _buildGridBox("Cash", data.expenses.cash, Colors.red.shade400)),
              const SizedBox(width: 8),
              Expanded(child: _buildGridBox("UPI/Online", data.expenses.upi, Colors.red.shade300)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClosingStockValue(DailyClosingAdminModel data) {
    return _buildCard(
      title: "Closing Stock Value (Estimated)",
      child: Column(
        children: [
          _buildRowItem("Total Trays", data.closingTrays.toString()),
          _buildRowItem("Est. Stock Value", formatCurrency(data.closingTrays * 150), isBold: true, textColor: Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildNotesChecklist(DailyClosingAdminModel data) {
    final isClosed = data.status == "CLOSED";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: "Notes",
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            enabled: !isClosed,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: "Enter any notes about today's closing...",
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        _buildCard(
          title: "Checklist",
          child: Column(
            children: [
              _buildCheckItem("Verified all Sales entries", "sales", isClosed),
              _buildCheckItem("Counted Physical Cash", "cash", isClosed),
              _buildCheckItem("Checked stock level", "stock", isClosed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String label, String key, bool isClosed) {
    final checked = checklist[key]! || isClosed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _toggleChecklist(key, isClosed ? "CLOSED" : "OPEN"),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              color: checked ? Colors.green : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context, DailyClosingAdminState state) {
    final isClosed = state.dashboardData?.status == "CLOSED";
    final isSubmitting = state.isSubmitting;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isClosed || isSubmitting
                ? null
                : () {
                    if (state.selectedBranchId != null) {
                      context.read<DailyClosingAdminBloc>().add(
                        SubmitDayClosingEvent(
                          branchId: state.selectedBranchId!,
                          status: "DRAFT",
                          notes: _notesController.text,
                          countedCash: double.tryParse(_countedCashController.text) ?? 0,
                        ),
                      );
                    }
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Save as Draft"),
          ),
        ),
        const SizedBox(width: 12),
        
        Expanded(
          child: ElevatedButton(
            onPressed: isClosed || isSubmitting || !isChecklistComplete
                ? null
                : () {
                    if (state.selectedBranchId != null) {
                      context.read<DailyClosingAdminBloc>().add(
                        SubmitDayClosingEvent(
                          branchId: state.selectedBranchId!,
                          status: "CLOSED",
                          notes: _notesController.text,
                          countedCash: double.tryParse(_countedCashController.text) ?? 0,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_box_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(isClosed ? "Day Closed" : "Close Day"),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value, {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: textColor ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridBox(String label, num value, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            formatCurrency(value),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
        ],
      ),
    );
  }
}
