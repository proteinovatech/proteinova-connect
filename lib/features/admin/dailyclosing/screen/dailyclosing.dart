import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  DailyClosingAdminModel? _loadedData;

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
    if (status == 'CLOSED') return;
    setState(() {
      checklist[key] = !checklist[key]!;
    });
  }

  String formatRupee(num val) {
    return "₹${val.ceil().toString()}";
  }

  void _initializeData(DailyClosingAdminModel data) {
    _notesController.text = data.notes;
    _countedCashController.text = (data.cashSummary?.counted ?? 0).toString();
    checklist = {
      'sales': false,
      'cash': false,
      'stock': false,
    };
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

        if (state.dashboardData != null && state.dashboardData != _loadedData) {
          _loadedData = state.dashboardData;
          _initializeData(state.dashboardData!);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Text("Daily Closing", style: AppTextStyles.headingText22),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFFD97706)),
                  SizedBox(width: 4),
                  Text(
                    "Admin",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
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

            final isClosed = state.dashboardData?.status == 'CLOSED';

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
                    // Action Bar
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
                      _buildCashSummary(state.dashboardData!, isClosed),
                      const SizedBox(height: 16),

                      // Online Transaction Summary Card
                      _buildOnlineSummary(state.dashboardData!),
                      const SizedBox(height: 16),

                      // Sales & Expenses double card structure
                      _buildDoubleCard(state.dashboardData!),
                      const SizedBox(height: 16),

                      // Closing Stock Value Estimated Card
                      _buildClosingStockValue(state.dashboardData!),
                      const SizedBox(height: 16),

                      // Notes & Checklist Section
                      _buildNotesChecklist(state.dashboardData!, isClosed),
                      const SizedBox(height: 16),

                      // Today's Summary Equation Card
                      _buildTodaysSummary(state.dashboardData!),
                      const SizedBox(height: 24),

                      // Bottom action buttons
                      _buildFooterActions(context, state, isClosed),
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
    final status = state.dashboardData?.status ?? "OPEN";
    final isClosed = status == "CLOSED";

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
            "Branch",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: state.selectedBranchId,
            style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 15),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: state.branches.map((BranchSelectorModel branch) {
              return DropdownMenuItem<int>(
                value: branch.id,
                child: Text(branch.branchName),
              );
            }).toList(),
            onChanged: (int? value) {
              if (value != null) {
                context.read<DailyClosingAdminBloc>().add(SelectBranchEvent(value));
              }
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Verify all details before closing the day. Once closed, entries cannot be edited",
                  style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isClosed ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isClosed ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Status: $status",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isClosed ? const Color(0xFF991B1B) : const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("History screen placeholder")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF475569),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("History", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStockSummary(DailyClosingAdminModel data) {
    final stock = data.stockSummary;
    final openingTrays = stock?.totalOpening ?? 0;
    final receivedTrays = stock?.totalReceived ?? 0;
    final soldTrays = stock?.totalSold ?? 0;
    final damagedTrays = stock?.totalDamaged ?? 0;
    final closingTrays = stock?.totalClosing ?? 0;

    final openingEggs = stock?.totalOpeningEggs ?? 0;
    final receivedEggs = stock?.totalReceivedEggs ?? 0;
    final soldEggs = stock?.totalSoldEggs ?? 0;
    final damagedEggs = stock?.totalDamagedEggs ?? 0;
    final closingEggs = stock?.totalClosingEggs ?? 0;

    return _buildCard(
      title: "Stock Summary",
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(110),
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              children: const [
                Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12))),
                Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Opening Stock", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12))),
                Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Received", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12))),
                Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Sold", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12))),
                Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Damaged", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12))),
                Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Closing Stock", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12))),
              ],
            ),
            TableRow(
              children: [
                const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Trays", style: TextStyle(color: Color(0xFF1E293B), fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(openingTrays.round().toString(), style: const TextStyle(fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(receivedTrays.round().toString(), style: const TextStyle(fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(soldTrays.round().toString(), style: const TextStyle(fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(damagedTrays.round().toString(), style: const TextStyle(fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(closingTrays.round().toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              ],
            ),
            TableRow(
              children: [
                const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("All Stocks Eggs", style: TextStyle(color: Color(0xFF1E293B), fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(openingEggs.round().toString(), style: const TextStyle(fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(receivedEggs.round().toString(), style: const TextStyle(fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(soldEggs.round().toString(), style: const TextStyle(fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(damagedEggs.round().toString(), style: const TextStyle(fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(closingEggs.round().toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              ],
            ),
            TableRow(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
              ),
              children: [
                const Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(openingTrays.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(receivedTrays.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(soldTrays.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(damagedTrays.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(closingTrays.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String label, String value, {bool isBold = false, Color? textColor, bool hasBottomBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: hasBottomBorder ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: textColor ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashSummary(DailyClosingAdminModel data, bool isClosed) {
    return _buildCard(
      title: "Cash Summary",
      child: Column(
        children: [
          _buildRowItem("Cash Sales", formatRupee(data.sales?.cash ?? 0)),
          _buildRowItem("Expenses (Cash)", formatRupee(data.expenses?.cash ?? 0)),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Closing Cash (Counted)", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("₹", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 120,
                      height: 36,
                      child: TextField(
                        controller: _countedCashController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isClosed ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                        ),
                        enabled: !isClosed,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          filled: isClosed,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineSummary(DailyClosingAdminModel data) {
    final upiSales = data.onlineSummary?.upi.sales ?? 0;
    final upiExpense = data.onlineSummary?.upi.expense ?? 0;
    final upiClosing = data.onlineSummary?.upi.closing ?? 0;

    final cardSales = data.onlineSummary?.card.sales ?? 0;
    final cardExpense = data.onlineSummary?.card.expense ?? 0;
    final cardClosing = data.onlineSummary?.card.closing ?? 0;

    final totalCollection = data.onlineSummary?.totalCollection ?? 0;

    return _buildCard(
      title: "Online Transaction Summary",
      child: Column(
        children: [
          _buildRowItem("UPI Sales", formatRupee(upiSales)),
          _buildRowItem("Expenses (UPI)", "-${formatRupee(upiExpense)}"),
          _buildRowItem("Closing UPI", formatRupee(upiClosing), isBold: true, hasBottomBorder: true),
          _buildRowItem("Card Sales", formatRupee(cardSales)),
          _buildRowItem("Expenses (Card)", "-${formatRupee(cardExpense)}"),
          _buildRowItem("Closing Card", formatRupee(cardClosing), isBold: true, hasBottomBorder: true),
          _buildRowItem("Total Collection", formatRupee(totalCollection), isBold: true, textColor: const Color(0xFF1E293B)),
        ],
      ),
    );
  }

  Widget _buildDoubleCard(DailyClosingAdminModel data) {
    return Column(
      children: [
        _buildCard(
          title: "Sales Summary",
          child: Row(
            children: [
              Expanded(
                child: _buildGridBox("Total Sales", formatRupee(data.salesSummary?.total ?? 0), const Color(0xFF6366F1), const Color(0xFFEEF2FF)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGridBox("Cash Sales", formatRupee(data.salesSummary?.cash ?? 0), const Color(0xFF22C55E), const Color(0xFFF0FDF4)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGridBox("UPI Sales / Online", formatRupee(data.salesSummary?.upi ?? 0), const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: "Expense Summary",
          child: Row(
            children: [
              Expanded(
                child: _buildGridBox("Total Expenses", formatRupee(data.expenseSummary?.total ?? 0), const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGridBox("Cash", formatRupee(data.expenseSummary?.cash ?? 0), const Color(0xFFF97316), const Color(0xFFFFF7ED)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGridBox("UPI / Online", formatRupee(data.expenseSummary?.upi ?? 0), const Color(0xFFEC4899), const Color(0xFFFDF2F8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridBox(String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildClosingStockValue(DailyClosingAdminModel data) {
    final eggs = data.closingStockValue?.eggs ?? 0;
    final plastic = data.closingStockValue?.plastic ?? 0;
    final paper = data.closingStockValue?.paper ?? 0;
    final empty = data.closingStockValue?.empty ?? 0;
    final total = data.closingStockValue?.total ?? 0;

    return _buildCard(
      title: "Closing Stock Value (Estimated)",
      child: Column(
        children: [
          _buildRowItem("Eggs (with trays)", formatRupee(eggs)),
          _buildRowItem("Plastic Trays", formatRupee(plastic)),
          _buildRowItem("Paper Trays", formatRupee(paper)),
          _buildRowItem("Empty Trays", formatRupee(empty), hasBottomBorder: true),
          _buildRowItem("Total Stock Value", formatRupee(total), isBold: true, textColor: const Color(0xFF1E293B)),
        ],
      ),
    );
  }

  Widget _buildNotesChecklist(DailyClosingAdminModel data, bool isClosed) {
    return Column(
      children: [
        _buildCard(
          title: "Notes",
          child: TextField(
            controller: _notesController,
            maxLines: 4,
            enabled: !isClosed,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: "Enter any notes about today's closing..",
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: "Checklist",
          child: Column(
            children: [
              _buildCheckItem("Verified all Sales entries", "sales", isClosed),
              const SizedBox(height: 12),
              _buildCheckItem("Counted Physical Cash", "cash", isClosed),
              const SizedBox(height: 12),
              _buildCheckItem("Checked stock level", "stock", isClosed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String label, String key, bool isClosed) {
    final isChecked = checklist[key]! || isClosed;

    return InkWell(
      onTap: isClosed ? null : () => _toggleChecklist(key, isClosed ? 'CLOSED' : 'OPEN'),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFF3B82F6) : Colors.white,
              border: Border.all(color: isChecked ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1), width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isChecked
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysSummary(DailyClosingAdminModel data) {
    final opening = data.todaysSummary?.openingStockValue ?? 0;
    final received = data.todaysSummary?.receivedStockValue ?? 0;
    final sold = data.todaysSummary?.soldStockValue ?? 0;
    final damaged = data.todaysSummary?.damagedStockValue ?? 0;
    final closing = data.todaysSummary?.closingStockValue ?? 0;

    return _buildCard(
      title: "Today's Summary",
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildEquationBox("Opening Stock Value", formatRupee(opening)),
            _buildEquationOperator("+"),
            _buildEquationBox("Stock Received Value", formatRupee(received)),
            _buildEquationOperator("-"),
            _buildEquationBox("Stock Sold Value", formatRupee(sold)),
            _buildEquationOperator("-"),
            _buildEquationBox("Stock Damaged Value", formatRupee(damaged)),
            _buildEquationOperator("="),
            _buildEquationBox("Closing Stock Value", formatRupee(closing), isResult: true),
          ],
        ),
      ),
    );
  }

  Widget _buildEquationBox(String label, String value, {bool isResult = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isResult ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isResult ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isResult ? const Color(0xFF2563EB) : const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildEquationOperator(String operator) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        operator,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context, DailyClosingAdminState state, bool isClosed) {
    final isSubmitting = state.isSubmitting;
    final enabledCloseDay = isChecklistComplete && !isClosed;

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
                          status: state.dashboardData?.status ?? "OPEN",
                          notes: _notesController.text,
                          countedCash: double.tryParse(_countedCashController.text) ?? 0.0,
                        ),
                      );
                    }
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Save as Draft",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Opacity(
            opacity: (!isChecklistComplete && !isClosed) || isClosed ? 0.6 : 1.0,
            child: ElevatedButton(
              onPressed: !enabledCloseDay || isSubmitting
                  ? () {
                      if (!isClosed && !isChecklistComplete) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please complete all checklist items first"),
                            backgroundColor: Colors.amber,
                          ),
                        );
                      }
                    }
                  : () {
                      if (state.selectedBranchId != null) {
                        context.read<DailyClosingAdminBloc>().add(
                          SubmitDayClosingEvent(
                            branchId: state.selectedBranchId!,
                            status: "CLOSED",
                            notes: _notesController.text,
                            countedCash: double.tryParse(_countedCashController.text) ?? 0.0,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isClosed ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_box_outlined, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          isClosed ? "Day Closed" : "Close Day",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
