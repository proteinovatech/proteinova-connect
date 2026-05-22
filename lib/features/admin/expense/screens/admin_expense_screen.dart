import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/expense/bloc/branch_expense_bloc.dart';
import 'package:proteinova_connect/features/admin/expense/bloc/branch_expense_event.dart';
import 'package:proteinova_connect/features/admin/expense/bloc/branch_expense_state.dart';
import 'package:proteinova_connect/features/admin/expense/data/models/branch_expense_dashboard_model.dart';

import 'package:proteinova_connect/features/admin/skeletonloader/admin_expense_management_skeleton_loader.dart';

import '../data/repository/expense_repository.dart';

import '../widgets/expense_category_item.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/expense_table_header.dart';
import '../widgets/expense_table_row.dart';
import '../widgets/expense_textfield.dart';

class AdminExpenseScreen extends StatefulWidget {
  const AdminExpenseScreen({super.key});

  @override
  State<AdminExpenseScreen> createState() => _AdminExpenseScreenState();
}

class _AdminExpenseScreenState extends State<AdminExpenseScreen> {
  final ExpenseRepository _repository = ExpenseRepository();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String selectedCategory = "Transport";
  String selectedPayment = "Cash";
  String selectedStatus = "Paid";
  int selectedBranchId = 1; // Default branch ID
  String selectedMonth = "2025-05"; // Default month

  Map<int, String> branches = {};

  Future<void> _fetchData() async {
    context.read<BranchExpenseBloc>().add(
      LoadDashboardEvent(branchId: selectedBranchId, month: selectedMonth),
    );
  }

  bool isSaving = false;
  BranchExpenseDashboardModel? dashboardData;

  double _getCategoryAmount(String categoryName) {
    if (dashboardData == null) return 0.0;
    try {
      return dashboardData!.categories
          .firstWhere(
            (e) => e.category.toUpperCase() == categoryName.toUpperCase(),
          )
          .amount;
    } catch (_) {
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    dateController.text = DateTime.now().toString().split(' ')[0];
    Future.microtask(() {
      context.read<BranchExpenseBloc>().add(LoadBranchesEvent());
    });
  }

  Future<void> _saveExpense() async {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter amount")));
      return;
    }

    setState(() => isSaving = true);
    try {
      await _repository.createBranchExpense(
        branchId: selectedBranchId,
        expenseDate: dateController.text,
        category: selectedCategory.toUpperCase(),
        amount: double.parse(amountController.text),
        paymentMethod: selectedPayment.toUpperCase(),
        description: descriptionController.text,
        status: selectedStatus.toUpperCase(),
      );

      amountController.clear();
      descriptionController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expense saved successfully")),
        );
      }
      context.read<BranchExpenseBloc>().add(
        LoadDashboardEvent(branchId: selectedBranchId, month: selectedMonth),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      // body: isLoading
      //     ? const AdminExpenseManagementSkeletonLoader()
      //     : RefreshIndicator(
      //         onRefresh: _fetchData,
      // backgroundColor:AppColors.lightGrey,
      body: BlocBuilder<BranchExpenseBloc, BranchExpenseState>(
        builder: (context, state) {
          final dashboardData = state.dashboardData;
          final branches = state.branches;
          final isLoading = state.isLoading;
          if (state.isLoading && state.dashboardData == null) {
            return const AdminExpenseManagementSkeletonLoader();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BranchExpenseBloc>().add(
                LoadDashboardEvent(
                  branchId: selectedBranchId,
                  month: selectedMonth,
                ),
              );
            },
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context, 18),
                  vertical: getHeight(context, 24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),

                        const SizedBox(width: 8),

                        const Expanded(
                          child: Text(
                            "Expense Management",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: getWidth(context, 14),
                            vertical: getHeight(context, 10),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.amber100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield_outlined, size: 18),
                              SizedBox(width: 6),
                              Text(
                                "Admin",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(context, 20)),

                    /// FILTERS
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: getHeight(context, 50),
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(context, 12),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: branches.containsKey(selectedBranchId)
                                    ? selectedBranchId
                                    : null,
                                hint: const Text("Select Branch"),
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                items: branches.entries.map((entry) {
                                  return DropdownMenuItem<int>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedBranchId = value;
                                    });
                                    context.read<BranchExpenseBloc>().add(
                                      LoadDashboardEvent(
                                        branchId: selectedBranchId,
                                        month: selectedMonth,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: getWidth(context, 4)),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                helpText: "Select Month",
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedMonth =
                                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}";
                                });
                                context.read<BranchExpenseBloc>().add(
                                  LoadDashboardEvent(
                                    branchId: selectedBranchId,
                                    month: selectedMonth,
                                  ),
                                );
                              }
                            },
                            child: dropdownBox(selectedMonth),
                          ),
                        ),

                        SizedBox(width: getWidth(context, 10)),

                        InkWell(
                          onTap: () async {
                            context.read<BranchExpenseBloc>().add(
                              LoadDashboardEvent(
                                branchId: selectedBranchId,
                                month: selectedMonth,
                              ),
                            );
                          },
                          child: Container(
                            height: getHeight(context, 50),
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(context, 20),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xffE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                isLoading
                                    ? SizedBox(
                                        height: getHeight(context, 20),
                                        width: getWidth(context, 20),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.refresh),
                                SizedBox(width: getWidth(context, 8)),
                                const Text(
                                  "Refresh",
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(context, 18)),

                    /// SUMMARY
                    Row(
                      children: [
                        ExpenseSummaryCard(
                          title: "Total Expenses (MTD)",
                          amount:
                              "₹${dashboardData?.cards.totalExpensesMtd.toStringAsFixed(2) ?? "0.00"}",
                          icon: Icons.currency_rupee,
                          iconBg: AppColors.blue100,

                          onTap: () {
                            showExpenseDetailsBottomSheet(
                              "Total Expenses (MTD)",
                            );
                          },
                        ),

                        SizedBox(width: getWidth(context, 12)),

                        ExpenseSummaryCard(
                          title: "Salary / Payroll",
                          amount:
                              "₹${dashboardData?.cards.salaryPayroll.toStringAsFixed(2) ?? "0.00"}",
                          icon: Icons.person_outline,
                          iconBg: AppColors.blue100,
                          onTap: () {
                            showExpenseDetailsBottomSheet("Salary / Payroll");
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(context, 12)),

                    Row(
                      children: [
                        ExpenseSummaryCard(
                          title: "Rent & Facilities",
                          amount:
                              "₹${dashboardData?.cards.rentFacilities.toStringAsFixed(2) ?? "0.00"}",
                          icon: Icons.apartment,
                          iconBg: AppColors.violet100,
                          onTap: () {
                            showExpenseDetailsBottomSheet("Rent");
                          },
                        ),

                        SizedBox(width: getWidth(context, 12)),

                        ExpenseSummaryCard(
                          title: "Transport & Fuel",
                          amount:
                              "₹${dashboardData?.cards.transportFuel.toStringAsFixed(2) ?? "0.00"}",
                          icon: Icons.local_shipping_outlined,
                          iconBg: AppColors.green100,
                          onTap: () {
                            showExpenseDetailsBottomSheet("Transport");
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(context, 12)),

                    Row(
                      children: [
                        ExpenseSummaryCard(
                          title: "Electricity",
                          amount:
                              "₹${_getCategoryAmount("ELECTRICITY").toStringAsFixed(2)}",
                          icon: Icons.bolt,
                          iconBg: AppColors.amber100,
                          onTap: () {
                            showExpenseDetailsBottomSheet("Electricity");
                          },
                        ),

                        SizedBox(width: getWidth(context, 12)),

                        ExpenseSummaryCard(
                          title: "Miscellaneous",
                          amount:
                              "₹${_getCategoryAmount("MISCELLANEOUS").toStringAsFixed(2)}",
                          icon: Icons.more_horiz,
                          iconBg: AppColors.lightGrey,
                          onTap: () {
                            showExpenseDetailsBottomSheet("Miscellaneous");
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(context, 12)),

                    Row(
                      children: [
                        ExpenseSummaryCard(
                          title: "Maintenance",
                          amount:
                              "₹${_getCategoryAmount("MAINTENANCE").toStringAsFixed(2)}",
                          icon: Icons.build,
                          iconBg: AppColors.red100,
                          onTap: () {
                            showExpenseDetailsBottomSheet("Maintenance");
                          },
                        ),

                        SizedBox(width: getWidth(context, 12)),

                        ExpenseSummaryCard(
                          title: "Other Expenses",
                          amount:
                              "₹${_getCategoryAmount("OTHER_EXPENSES").toStringAsFixed(2)}",
                          icon: Icons.groups,
                          iconBg: AppColors.teal100,
                          onTap: () {
                            showExpenseDetailsBottomSheet("Other_Expenses");
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(context, 24)),

                    /// CATEGORY BREAKDOWN TABLE
                    Text(
                      "Category Breakdown",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: getHeight(context, 12)),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          /// TABLE HEADER
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(context, 16),
                              vertical: getHeight(context, 12),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "CATEGORY",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "TOTAL AMOUNT",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// TABLE ROWS
                          if (dashboardData != null)
                            ...dashboardData.categories.map(
                              (cat) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: getWidth(context, 16),
                                  vertical: getHeight(context, 12),
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade100,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        cat.category,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "₹${cat.amount.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          if (dashboardData == null ||
                              dashboardData.categories.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "No category data available",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: getHeight(context, 18)),

                    /// ADD EXPENSE
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Add Expense",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),

                          SizedBox(height: getHeight(context, 18)),

                          const Text("Expense Date *"),

                          SizedBox(height: getHeight(context, 10)),

                          GestureDetector(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                setState(() {
                                  dateController.text = picked.toString().split(
                                    ' ',
                                  )[0];
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: ExpenseTextField(
                                hint: "YYYY-MM-DD",
                                controller: dateController,
                                prefixIcon: const Icon(Icons.calendar_month),
                              ),
                            ),
                          ),

                          SizedBox(height: getHeight(context, 18)),

                          const Text("Expense Category *"),

                          SizedBox(height: getHeight(context, 10)),

                          dropdownField(),

                          SizedBox(height: getHeight(context, 18)),

                          const Text("Amount (₹) *"),

                          SizedBox(height: getHeight(context, 10)),

                          ExpenseTextField(
                            hint: "e.g. 500",
                            controller: amountController,
                          ),

                          SizedBox(height: getHeight(context, 18)),

                          const Text("Payment Method *"),

                          SizedBox(height: getHeight(context, 10)),

                          Row(
                            children: [
                              paymentButton("Cash"),

                              SizedBox(width: getWidth(context, 14)),

                              paymentButton("UPI"),

                              SizedBox(width: getWidth(context, 14)),

                              paymentButton("Card"),
                            ],
                          ),

                          SizedBox(height: getHeight(context, 18)),

                          const Text("Status"),

                          SizedBox(height: getHeight(context, 10)),

                          Row(
                            children: [
                              statusButton("Paid"),

                              SizedBox(width: getWidth(context, 14)),

                              statusButton("Pending"),
                            ],
                          ),

                          SizedBox(height: getHeight(context, 18)),

                          const Text("Description"),

                          SizedBox(height: getHeight(context, 10)),

                          ExpenseTextField(
                            hint: "e.g. Transport for stock from warehouse",
                            controller: descriptionController,
                            maxLines: 3,
                          ),

                          SizedBox(height: getHeight(context, 12)),

                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: getHeight(context, 48),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffF3F4F6),
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      amountController.clear();
                                      descriptionController.clear();
                                    },
                                    child: const Text("Reset"),
                                  ),
                                ),
                              ),

                              SizedBox(width: getWidth(context, 16)),

                              Expanded(
                                child: SizedBox(
                                  height: getHeight(context, 48),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.amber600,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: isSaving ? null : _saveExpense,
                                    child: isSaving
                                        ? SizedBox(
                                            width: getWidth(context, 20),
                                            height: getHeight(context, 20),
                                            child: CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text("Save Expense"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: getHeight(context, 24)),

                    /// CATEGORIES
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Expense Categories",
                            style: TextStyle(
                              fontSize: getWidth(context, 20),
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizedBox(height: getHeight(context, 20)),

                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),

                            mainAxisSpacing: 0,
                            crossAxisSpacing: 2,

                            childAspectRatio: 0.70,
                            children: [
                              InkWell(
                                onTap: () =>
                                    setState(() => selectedCategory = "Rent"),
                                child: ExpenseCategoryItem(
                                  title: "Rent",
                                  icon: Icons.apartment,
                                  bgColor: selectedCategory == "Rent"
                                      ? AppColors.blue100
                                      : AppColors.violet100,
                                ),
                              ),

                              InkWell(
                                onTap: () =>
                                    setState(() => selectedCategory = "Salary"),
                                child: ExpenseCategoryItem(
                                  title: "Salary",
                                  icon: Icons.person_outline,
                                  bgColor: selectedCategory == "Salary"
                                      ? AppColors.blue100
                                      : AppColors.blue100,
                                ),
                              ),

                              InkWell(
                                onTap: () => setState(
                                  () => selectedCategory = "Electricity",
                                ),
                                child: ExpenseCategoryItem(
                                  title: "Electricity",
                                  icon: Icons.bolt,
                                  bgColor: selectedCategory == "Electricity"
                                      ? AppColors.blue100
                                      : AppColors.amber100,
                                ),
                              ),

                              InkWell(
                                onTap: () => setState(
                                  () => selectedCategory = "Miscellaneous",
                                ),
                                child: ExpenseCategoryItem(
                                  title: "Miscellaneous",
                                  icon: Icons.more_horiz,
                                  bgColor: selectedCategory == "Miscellaneous"
                                      ? AppColors.blue100
                                      : AppColors.lightGrey,
                                ),
                              ),

                              InkWell(
                                onTap: () => setState(
                                  () => selectedCategory = "Transport",
                                ),
                                child: ExpenseCategoryItem(
                                  title: "Transport",
                                  icon: Icons.local_shipping_outlined,
                                  bgColor: selectedCategory == "Transport"
                                      ? AppColors.blue100
                                      : AppColors.green100,
                                ),
                              ),

                              InkWell(
                                onTap: () => setState(
                                  () => selectedCategory = "Packing",
                                ),
                                child: ExpenseCategoryItem(
                                  title: "Packing",
                                  icon: Icons.inventory_2,
                                  bgColor: selectedCategory == "Packing"
                                      ? AppColors.blue100
                                      : AppColors.violet100,
                                ),
                              ),

                              InkWell(
                                onTap: () => setState(
                                  () => selectedCategory = "Maintenance",
                                ),
                                child: ExpenseCategoryItem(
                                  title: "Maintenance",
                                  icon: Icons.build,
                                  bgColor: selectedCategory == "Maintenance"
                                      ? AppColors.blue100
                                      : AppColors.red100,
                                ),
                              ),

                              InkWell(
                                onTap: () => setState(
                                  () => selectedCategory = "Other Expenses",
                                ),
                                child: ExpenseCategoryItem(
                                  title: "Other Expenses",
                                  icon: Icons.groups,
                                  bgColor: selectedCategory == "Other Expenses"
                                      ? AppColors.blue100
                                      : AppColors.teal100,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: getHeight(context, 24)),

                    /// RECENT EXPENSES
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Recent Expenses",
                            style: TextStyle(
                              fontSize: getWidth(context, 22),
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizedBox(height: getHeight(context, 20)),

                          const ExpenseTableHeader(),

                          SizedBox(height: getHeight(context, 20)),

                          if (isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (dashboardData == null ||
                              dashboardData.recentExpenses.isEmpty)
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),

                                  SizedBox(height: getHeight(context, 12)),

                                  const Text(
                                    "No expenses found for this branch & month.",
                                    style: TextStyle(color: Color(0xff6B7280)),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dashboardData.recentExpenses.length,
                              itemBuilder: (context, index) {
                                return ExpenseTableRow(
                                  expense: dashboardData.recentExpenses[index],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget dropdownBox(String title) {
    return Container(
      height: getHeight(context, 48),
      padding: EdgeInsets.symmetric(horizontal: getWidth(context, 18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),

          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget dropdownField() {
    return Container(
      height: getHeight(context, 43),
      padding: EdgeInsets.symmetric(horizontal: getWidth(context, 16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined),

          SizedBox(width: getWidth(context, 10)),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items:
                    [
                          "Rent",
                          "Salary",
                          "Electricity",
                          "Miscellaneous",
                          "Transport",
                          "Packing",
                          "Maintenance",
                          "Other Expenses",
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentButton(String text) {
    final bool isSelected = selectedPayment == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPayment = text;
          });
        },

        child: Container(
          height: getHeight(context, 48),
          alignment: Alignment.center,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.blue : const Color(0xffE5E7EB),
            ),
          ),

          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget statusButton(String text) {
    final bool isSelected = selectedStatus == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = text;
          });
        },

        child: Container(
          height: getHeight(context, 48),
          alignment: Alignment.center,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.blue : const Color(0xffE5E7EB),
            ),
          ),

          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  //show expense details
  void showExpenseDetailsBottomSheet(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,

          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),

          child: Column(
            children: [
              /// HANDLE
              SizedBox(height: getHeight(context, 20)),

              Container(
                width: getWidth(context, 70),
                height: getHeight(context, 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              SizedBox(height: getHeight(context, 16)),

              /// HEADER
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context, 24),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "$title Details",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: const Icon(Icons.close, size: 30),
                    ),
                  ],
                ),
              ),

              SizedBox(height: getHeight(context, 24)),

              /// TABLE
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(context, 24),
                  ),

                  child: Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xffE5E7EB)),
                    ),

                    child: Column(
                      children: [
                        /// HORIZONTAL TABLE
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: SizedBox(
                              width: getWidth(context, 500),

                              child: Column(
                                children: [
                                  /// HEADER
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: getWidth(context, 18),
                                      vertical: getHeight(context, 18),
                                    ),

                                    decoration: const BoxDecoration(
                                      color: Color(0xffF9FAFB),

                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),

                                    child: Row(
                                      children: [
                                        headerItem("Date", 80),

                                        headerItem("Category", 80),

                                        headerItem("Description", 80),

                                        headerItem("Amount", 80),

                                        headerItem("Status", 80),
                                      ],
                                    ),
                                  ),

                                  /// DATA LIST
                                  if (dashboardData != null)
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: dashboardData!.recentExpenses
                                            .where(
                                              (e) =>
                                                  title ==
                                                      "Total Expenses (MTD)" ||
                                                  e.category.toUpperCase() ==
                                                      title.toUpperCase() ||
                                                  (title ==
                                                          "Salary / Payroll" &&
                                                      e.category
                                                              .toUpperCase() ==
                                                          "SALARY") ||
                                                  (title ==
                                                          "Rent & Facilities" &&
                                                      e.category
                                                              .toUpperCase() ==
                                                          "RENT") ||
                                                  (title ==
                                                          "Transport & Fuel" &&
                                                      e.category
                                                              .toUpperCase() ==
                                                          "TRANSPORT"),
                                            )
                                            .length,
                                        itemBuilder: (context, index) {
                                          final filteredList = dashboardData!
                                              .recentExpenses
                                              .where(
                                                (e) =>
                                                    title ==
                                                        "Total Expenses (MTD)" ||
                                                    e.category.toUpperCase() ==
                                                        title.toUpperCase() ||
                                                    (title ==
                                                            "Salary / Payroll" &&
                                                        e.category
                                                                .toUpperCase() ==
                                                            "SALARY") ||
                                                    (title ==
                                                            "Rent & Facilities" &&
                                                        e.category
                                                                .toUpperCase() ==
                                                            "RENT") ||
                                                    (title ==
                                                            "Transport & Fuel" &&
                                                        e.category
                                                                .toUpperCase() ==
                                                            "TRANSPORT"),
                                              )
                                              .toList();
                                          final e = filteredList[index];
                                          return Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: getWidth(context, 18),
                                              vertical: getHeight(context, 14),
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey.shade200,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                headerItem(e.expenseDate, 80),
                                                headerItem(e.category, 80),
                                                headerItem(e.description, 80),
                                                headerItem(e.amount, 80),
                                                headerItem(e.status, 80),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,

                                          children: [
                                            Icon(
                                              Icons.receipt_long,
                                              size: 90,
                                              color: Colors.grey.shade300,
                                            ),

                                            const SizedBox(height: 20),

                                            const Text(
                                              "No records found.",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),

                                            const SizedBox(height: 14),

                                            const Text(
                                              "There are no expense records for this branch\nin the selected month.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                height: 1.5,
                                                color: Color(0xff6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// CLOSE BUTTON
              Padding(
                padding: const EdgeInsets.all(24),

                child: SizedBox(
                  width: double.infinity,
                  height: getHeight(context, 58),

                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),

                      side: const BorderSide(color: Color(0xffE5E7EB)),
                    ),

                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget headerItem(String text, double width) {
    return SizedBox(
      width: width,

      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xff6B7280),
        ),
      ),
    );
  }
}
