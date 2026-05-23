import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/daily_closing/bloc/daily_closing_bloc.dart';
import 'package:proteinova_connect/features/branch/daily_closing/data/model/daily_closing_model.dart';
import 'package:proteinova_connect/features/branch/daily_closing/widget/daily_closing_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyClosing extends StatefulWidget {
  const DailyClosing({super.key});

  @override
  State<DailyClosing> createState() => _DailyClosingState();
}

class _DailyClosingState extends State<DailyClosing> {
  int? branchId;
  int? userId;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _countedCashController = TextEditingController();

  Map<String, bool> checklist = {'sales': false, 'cash': false, 'stock': false};

  @override
  void initState() {
    super.initState();
    _loadBranchIdAndFetch();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _countedCashController.dispose();
    super.dispose();
  }

  Future<void> _loadBranchIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    branchId = prefs.getInt("branch_id");
    userId = prefs.getInt("user_id");
    if (branchId != null) {
      _fetchData();
    }
  }

  void _fetchData() {
    context.read<DailyClosingBloc>().add(
      FetchDailyClosingData(
        branchId: branchId!,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );
  }

  bool get isChecklistComplete =>
      checklist['sales']! && checklist['cash']! && checklist['stock']!;

  void _toggleChecklist(String key, String status) {
    if (status == "CLOSED") return;
    setState(() {
      checklist[key] = !checklist[key]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DailyClosingBloc, DailyClosingState>(
      listener: (context, state) {
        if (state is DailyClosingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _fetchData();
        } else if (state is DailyClosingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is DailyClosingLoaded) {
          _notesController.text = state.model.notes;
          _countedCashController.text = state.model.cashSummary.counted
              .toString();
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
            Padding(
              padding: const EdgeInsets.only(right: 16),
              // child: Row(
              //   // children: [
              //   //   const Icon(
              //   //     Icons.verified_user_outlined,
              //   //     size: 18,
              //   //     color: AppColors.amber600,
              //   //   ),
              //   //   const SizedBox(width: 4),
              //   //   Text(
              //   //     "Branch",
              //   //     style: TextStyle(
              //   //       color: AppColors.amber600,
              //   //       fontWeight: FontWeight.bold,
              //   //     ),
              //   //   ),
              //   // ],
              // ),
            ),
          ],
        ),
        body: BlocBuilder<DailyClosingBloc, DailyClosingState>(
          builder: (context, state) {
            if (state is DailyClosingLoading) {
              return const DailyClosingSkeleton();
            }

            DailyClosingModel? data;
            if (state is DailyClosingLoaded) {
              data = state.model;
            } else if (state is DailyClosingSubmitting ||
                state is DailyClosingSuccess) {
              // Logic to keep data visible during submission could be added here
            }

            if (data == null) {
              return const Center(child: Text("Failed to load data."));
            }

            final isClosed = data.status == "CLOSED";
            final systemClosing = data.cashSummary.closing;
            final countedCash =
                double.tryParse(_countedCashController.text) ?? 0;
            final difference = countedCash - systemClosing;

            final width = MediaQuery.of(context).size.width;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: width >= 700
                  // Tablet
                  ? Wrap(
                      spacing: 16,
                      runSpacing: 16,

                      children: [
                        SizedBox(width: width, child: _buildActionBar(data!)),

                        SizedBox(
                          width: (width - 48) / 2,

                          child: _buildStockSummary(data),
                        ),

                        SizedBox(
                          width: (width - 48) / 2,

                          child: _buildCashSummary(data, isClosed, difference),
                        ),

                        SizedBox(
                          width: (width - 48) / 2,

                          child: _buildOnlineSummary(data),
                        ),

                        SizedBox(
                          width: (width - 48) / 2,

                          child: _buildSalesExpenseSummary(data),
                        ),

                        SizedBox(
                          width: (width - 48) / 2,

                          child: _buildClosingStockValue(data),
                        ),

                        SizedBox(
                          width: (width - 48) / 2,

                          child: _buildNotesChecklist(data, isClosed),
                        ),

                        SizedBox(
                          width: width,

                          child: _buildTodaysSummary(data),
                        ),

                        SizedBox(
                          width: width,

                          child: _buildFooterActions(
                            data,
                            isClosed,
                            state is DailyClosingSubmitting,
                          ),
                        ),
                      ],
                    )
                  // Mobile
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        _buildActionBar(data),

                        const SizedBox(height: 16),

                        _buildStockSummary(data),

                        const SizedBox(height: 16),

                        _buildCashSummary(data, isClosed, difference),

                        const SizedBox(height: 16),

                        _buildOnlineSummary(data),

                        const SizedBox(height: 16),

                        _buildSalesExpenseSummary(data),

                        const SizedBox(height: 16),

                        _buildClosingStockValue(data),

                        const SizedBox(height: 16),

                        _buildNotesChecklist(data, isClosed),

                        const SizedBox(height: 16),

                        _buildTodaysSummary(data),

                        const SizedBox(height: 24),

                        _buildFooterActions(
                          data,
                          isClosed,
                          state is DailyClosingSubmitting,
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionBar(DailyClosingModel data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Branch",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  data.branchName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: data.status == "OPEN"
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: data.status == "OPEN"
                      ? Colors.green
                      : Colors.red,
                ),

                const SizedBox(width: 8),

                Text(
                  "Status: ${data.status}",
                  style: TextStyle(
                    color: data.status == "OPEN" ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSummary(DailyClosingModel data) {
    return _buildCard(
      title: "Stock Summary",

      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),

              child: DataTable(
                columnSpacing: 6,

                horizontalMargin: 8,

                headingRowHeight: 42,

                dataRowMinHeight: 48,

                dataRowMaxHeight: 52,

                columns: const [
                  DataColumn(
                    label: SizedBox(
                      width: 90,

                      child: Text(
                        "Item",

                        style: TextStyle(
                          fontSize: 12,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      "Opening",
                      style: TextStyle(
                        fontSize: 12,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      "Received",
                      style: TextStyle(
                        fontSize: 12,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      "Sold",
                      style: TextStyle(
                        fontSize: 12,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      "Closing",
                      style: TextStyle(
                        fontSize: 12,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                rows: [
                  _buildStockRow(
                    "Trays",

                    data.stockSummary.totalOpening,

                    data.stockSummary.totalReceived,

                    data.stockSummary.totalSold,

                    data.stockSummary.totalClosing,
                  ),

                  _buildStockRow(
                    "All Stocks Eggs",

                    data.stockSummary.totalOpeningEggs,

                    data.stockSummary.totalReceivedEggs,

                    data.stockSummary.totalSoldEggs,

                    data.stockSummary.totalClosingEggs,
                  ),

                  _buildStockRow(
                    "Total",

                    data.stockSummary.totalOpening,

                    data.stockSummary.totalReceived,

                    data.stockSummary.totalSold,

                    data.stockSummary.totalClosing,

                    isBold: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildStockRow(
    String item,
    num op,
    num rec,
    num sold,
    num cls, {
    bool isBold = false,
  }) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return DataRow(
      cells: [
        DataCell(Text(item, style: style)),
        DataCell(Text(op.toStringAsFixed(1), style: style)),
        DataCell(Text(rec.toStringAsFixed(1), style: style)),
        DataCell(Text(sold.toStringAsFixed(1), style: style)),
        DataCell(Text(cls.toStringAsFixed(1), style: style)),
      ],
    );
  }

  Widget _buildCashSummary(
    DailyClosingModel data,
    bool isClosed,
    double difference,
  ) {
    return _buildCard(
      title: "Cash Summary",
      child: Column(
        children: [
          _buildSummaryItem(
            "Cash Sales",
            "₹${data.sales.cash.toStringAsFixed(2)}",
          ),
          _buildSummaryItem(
            "Closing Cash (System)",
            "₹${data.cashSummary.closing.toStringAsFixed(2)}",
          ),
          _buildSummaryItem(
            "Expenses (Cash)",
            "₹${data.expenses.cash.toStringAsFixed(2)}",
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Closing Cash (Counted)",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  width: 120,
                  height: 35,
                  child: TextField(
                    controller: _countedCashController,
                    keyboardType: TextInputType.number,
                    enabled: !isClosed,
                    textAlign: TextAlign.right,
                    onChanged: (v) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      filled: isClosed,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // _buildSummaryItem(
          //   "Difference",
          //   "₹${difference.toStringAsFixed(2)}",
          //   valueColor: difference == 0 ? Colors.green : Colors.red,
          //   isBold: true,
          // ),
        ],
      ),
    );
  }

  Widget _buildOnlineSummary(DailyClosingModel data) {
    return _buildCard(
      title: "Online Transaction Summary",
      child: Column(
        children: [
          _buildSummaryItem(
            "Expenses (UPI)",
            "-₹${data.onlineSummary.upi.expense.toStringAsFixed(2)}",
          ),
          _buildSummaryItem(
            "Closing UPI",
            "₹${data.onlineSummary.upi.closing.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
            "Card Sales",
            "₹${data.onlineSummary.card.sales.toStringAsFixed(2)}",
          ),
          _buildSummaryItem(
            "Expenses (Card)",
            "-₹${data.onlineSummary.card.expense.toStringAsFixed(2)}",
          ),
          _buildSummaryItem(
            "Closing Card",
            "₹${data.onlineSummary.card.closing.toStringAsFixed(2)}",
          ),
          const Divider(),
          _buildSummaryItem(
            "Total Collection",
            "₹${data.onlineSummary.totalCollection.toStringAsFixed(2)}",
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesExpenseSummary(DailyClosingModel data) {
    return Column(
      children: [
        _buildCard(
          title: "Sales Summary",
          child: Row(
            children: [
              Expanded(child: _buildStatBox("Total", data.sales.total)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatBox("Cash", data.sales.cash)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatBox("UPI", data.sales.upi)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: "Expense Summary",
          child: Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  "Total",
                  data.expenses.total,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox(
                  "Cash",
                  data.expenses.cash,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox(
                  "UPI",
                  data.expenses.upi,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClosingStockValue(DailyClosingModel data) {
    return _buildCard(
      title: "Closing Stock Value (Estimated)",
      child: Column(
        children: [
          _buildSummaryItem(
            "Eggs (with trays)",
            "₹${data.closingStockValue.eggs.toStringAsFixed(2)}",
          ),
          _buildSummaryItem(
            "Plastic Trays",
            "₹${data.closingStockValue.plastic.toStringAsFixed(2)}",
          ),
          _buildSummaryItem(
            "Paper Trays",
            "₹${data.closingStockValue.paper.toStringAsFixed(2)}",
          ),
          _buildSummaryItem(
            "Empty Trays",
            "₹${data.closingStockValue.empty.toStringAsFixed(2)}",
          ),
          const Divider(),
          _buildSummaryItem(
            "Total Stock Value",
            "₹${data.closingStockValue.total.toStringAsFixed(2)}",
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesChecklist(DailyClosingModel data, bool isClosed) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildCard(
            title: "Notes",
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              enabled: !isClosed,
              decoration: InputDecoration(
                hintText: "Add notes...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildCard(
            title: "Checklist",
            child: Column(
              children: [
                _buildCheckItem(
                  "Verified all Sales entries",
                  "sales",
                  isClosed,
                ),
                _buildCheckItem("Counted Physical Cash", "cash", isClosed),
                _buildCheckItem("Checked stock level", "stock", isClosed),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String text, String key, bool isClosed) {
    final isChecked = checklist[key]! || isClosed;
    return GestureDetector(
      onTap: () => _toggleChecklist(key, isClosed ? "CLOSED" : "PENDING"),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: isChecked ? AppColors.green : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 11))),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysSummary(DailyClosingModel data) {
    return _buildCard(
      title: "Today's Summary",
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFormulaItem(
              "Opening Stock",
              data.todaysSummary.openingStockValue,
            ),
            _buildOperator("+"),
            _buildFormulaItem(
              "Stock Received",
              data.todaysSummary.receivedStockValue,
            ),
            _buildOperator("+"),
            _buildFormulaItem("Total Sales", data.todaysSummary.totalSales),
            _buildOperator("-"),
            _buildFormulaItem(
              "Total Expenses",
              data.todaysSummary.totalExpenses,
            ),
            _buildOperator("="),
            _buildFormulaItem(
              "Final Value",
              data.todaysSummary.finalValue,
              isResult: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaItem(String label, num value, {bool isResult = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isResult ? 16 : 14,
            color: isResult ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildOperator(String op) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        op,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildFooterActions(
    DailyClosingModel data,
    bool isClosed,
    bool isSubmitting,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isClosed || isSubmitting ? null : () => _submit("DRAFT"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Save as Draft"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isClosed || isSubmitting || !isChecklistComplete
                ? null
                : () => _submit("CLOSED"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber600,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Close Day",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  void _submit(String status) {
    if (branchId == null) return;
    context.read<DailyClosingBloc>().add(
      SubmitDailyClosing(
        branchId: branchId!,
        status: status,
        notes: _notesController.text,
        countedCash: double.tryParse(_countedCashController.text) ?? 0,
        loginUserId: userId,
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
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.02),
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

  Widget _buildSummaryItem(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, num value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            "₹${value.toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
