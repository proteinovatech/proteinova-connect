import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/daily_closing/bloc/daily_closing_bloc.dart';
import 'package:proteinova_connect/features/branch/daily_closing/data/model/daily_closing_model.dart';
import 'package:proteinova_connect/features/branch/daily_closing/widget/checkitem.dart';
import 'package:proteinova_connect/features/branch/daily_closing/widget/infobox.dart';
import 'package:proteinova_connect/features/branch/daily_closing/widget/summary_block.dart';
import 'package:proteinova_connect/features/branch/daily_closing/widget/summary_item.dart';
import 'package:proteinova_connect/features/branch/daily_closing/widget/summary_row.dart';
import 'package:proteinova_connect/features/branch/sales/widget/buildrow.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyClosing extends StatefulWidget {
  const DailyClosing({super.key});

  @override
  State<DailyClosing> createState() => _DailyClosingState();
}

class _DailyClosingState extends State<DailyClosing> {
  bool isExpanded = true;
  int? branchId;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadBranchIdAndFetch();
  }

  Future<void> _loadBranchIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    branchId = prefs.getInt("branch_id");
    if (branchId != null) {
      context.read<DailyClosingBloc>().add(
        FetchDailyClosingData(branchId: branchId!, date: currentDate),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocListener<DailyClosingBloc, DailyClosingState>(
      listener: (context, state) {
        if (state is DailyClosingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is DailyClosingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background1,
        body: BlocBuilder<DailyClosingBloc, DailyClosingState>(
          builder: (context, state) {
            if (state is DailyClosingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DailyClosingError && branchId == null) {
              return Center(child: Text("Error: ${state.message}"));
            }

            DailyClosingModel? data;
            if (state is DailyClosingLoaded) {
              data = state.model;
            } else if (state is DailyClosingSubmitting || state is DailyClosingSuccess) {
              // Keep showing previous data if available
            }

            if (data == null) {
              return const Center(child: Text("No data available"));
            }

            double grandTotal = data.openingTrays.toDouble() + 
                                data.receivedTrays.toDouble() + 
                                data.sales.total - 
                                data.expenses.total;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.07),
                    Text("Daily Closing", style: AppTextStyles.headingText22),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      "Verify all details before closing the day. Once closed, entries cannot be edited",
                      style: AppTextStyles.bodyText14,
                    ),
                    SizedBox(height: size.height * 0.01),
                    const Divider(),
                    SizedBox(height: size.height * 0.01),
                    
                    // Stock Summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Stock Summary", style: AppTextStyles.headingText20),
                              IconButton(
                                icon: Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            SizedBox(height: size.height * 0.02),
                            _buildStockSection(size, "Eggs (With trays)", data.openingTrays, data.receivedTrays, data.soldTrays, data.closingTrays),
                            SizedBox(height: size.height * 0.02),
                            _buildStockSection(size, "Paper Trays (With Eggs)", data.openingTrays, data.receivedTrays, data.soldTrays, data.closingTrays),
                            SizedBox(height: size.height * 0.02),
                            _buildStockSection(size, "Empty Trays", data.openingTrays, data.receivedTrays, data.soldTrays, data.closingTrays),
                            SizedBox(height: size.height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total", style: AppTextStyles.headingText22),
                                Container(
                                  height: 35,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    border: Border.all(color: AppColors.border2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${data.closingTrays}",
                                      style: AppTextStyles.headingText20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.02),

                    // Sales & Expense Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                        color: AppColors.background,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sales Summary", style: AppTextStyles.headingText20),
                          SizedBox(height: size.height * 0.01),
                          Row(
                            children: [
                              Expanded(child: infoBox("₹${data.sales.total}", "Total Sales")),
                              const SizedBox(width: 10),
                              Expanded(child: infoBox("₹${data.sales.cash}", "Cash Sales")),
                              const SizedBox(width: 10),
                              Expanded(child: infoBox("₹${data.sales.upi}", "UPI Sales")),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Expense Summary", style: AppTextStyles.headingText20),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: infoBox("₹${data.expenses.total}", "Total")),
                                    const SizedBox(width: 10),
                                    Expanded(child: infoBox("₹${data.expenses.cash}", "Cash")),
                                    const SizedBox(width: 10),
                                    Expanded(child: infoBox("₹${data.expenses.upi}", "UPI")),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // Cash & Online Transaction Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          SummaryBlock(
                            heading: "Cash Summary",
                            items: [
                              SummaryItem("Opening Cash", "₹${data.sales.cash}"), // Placeholder logic from original file
                              SummaryItem("Added Cash", "₹${data.sales.cash}"),
                              SummaryItem("Cash Sales", "₹${data.sales.cash}"),
                              SummaryItem("Expenses", "₹${data.expenses.cash}"),
                              SummaryItem("Closing Cash", "₹${data.sales.cash}"),
                              SummaryItem("Difference", "₹0.00"),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          SummaryBlock(
                            heading: "Online Transaction Summary",
                            items: [
                              SummaryItem("UPI Sales", "₹${data.sales.upi}"),
                              SummaryItem("Expenses(UPI)", "₹${data.expenses.upi}"),
                              SummaryItem("Closing UPI", "₹${data.sales.upi}"),
                              SummaryItem("Card Sales", "₹${data.sales.card}"),
                              SummaryItem("Expenses(Card)", "₹${data.expenses.card}"),
                              SummaryItem("Online Sales", "₹${data.sales.online}"),
                              SummaryItem("Total Collection", "₹${data.sales.total}"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.01),

                    // Closing Stock Value
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Text("Closing Stock Value (Estimated)", style: AppTextStyles.headingText20),
                          SizedBox(height: size.height * 0.02),
                          buildSummaryRow("Opening Trays", "${data.openingTrays}"),
                          buildSummaryRow("Received Trays", "${data.receivedTrays}"),
                          buildSummaryRow("Sold Trays", "${data.soldTrays}"),
                          buildSummaryRow("Closing Trays", "${data.closingTrays}"),
                          const Divider(),
                          buildSummaryRow("Total Stock Value", "${data.closingTrays}", isBold: true),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // Today's summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Today's summary", style: AppTextStyles.headingText20),
                          SizedBox(height: size.height * 0.01),
                          summaryRow("Opening Stock Value", "₹${data.openingTrays}"), // Or use actual value if available
                          summaryRow("Stock Received Value", "₹${data.receivedTrays}"),
                          summaryRow("Total Sales", "₹${data.sales.total}"),
                          SizedBox(height: size.height * 0.01),
                          const Divider(),
                          summaryRow("Total Expenses", "₹${data.expenses.total}"),
                          SizedBox(height: size.height * 0.01),
                          const Divider(),
                          summaryRow("Grand Total", "₹${grandTotal.toInt()}"),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.01),

                    // Checklist
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Checklist", style: AppTextStyles.headingText20),
                          SizedBox(height: size.height * 0.02),
                          CheckItem(text: "Verified All Sales Entries"),
                          CheckItem(text: "Counted Physical Cash"),
                          CheckItem(text: "Checked Stock level"),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border2),
                          ),
                          child: Text("Save as Draft", style: AppTextStyles.containerText),
                        ),
                        SizedBox(width: size.width * 0.02),
                        GestureDetector(
                          onTap: () => _showCloseDayDialog(context),
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border2),
                            ),
                            alignment: Alignment.center,
                            child: state is DailyClosingSubmitting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text("Close Day", style: AppTextStyles.containerText),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockSection(Size size, String title, int opening, int received, int sold, int closing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyText14dark),
          SizedBox(height: size.height * 0.02),
          Row(
            children: [
              Expanded(child: stockItem("$opening", "Opening Stock")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("$received", "Received")),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            children: [
              Expanded(child: stockItem("$sold", "Sold")),
              const SizedBox(width: 10),
              Expanded(child: stockItem("$closing", "Closing")),
            ],
          ),
        ],
      ),
    );
  }

  void _showCloseDayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to close the day? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (branchId != null) {
                  context.read<DailyClosingBloc>().add(
                    SubmitDailyClosing(branchId: branchId!, date: currentDate),
                  );
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Widget stockItem(String value, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
