import 'package:flutter/material.dart';

import '../data/expense_repository.dart';
import '../models/branch_expense_dashboard_model.dart';
import '../models/expense_model.dart';
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

  bool isLoading = true;
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
    _initData();
  }

  Future<void> _initData() async {
    await _fetchBranches();
    if (branches.isNotEmpty) {
      // Set default branch to the first one fetched
      selectedBranchId = branches.keys.first;
      _fetchData();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchBranches() async {
    try {
      final fetchedBranches = await _repository.fetchBranches();
      setState(() {
        branches = fetchedBranches;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching branches: $e")));
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final data = await _repository.fetchBranchExpenses(
        branchId: selectedBranchId,
        month: selectedMonth,
      );
      setState(() {
        dashboardData = data;
        if (dashboardData != null) {
          dashboardData!.recentExpenses.sort(
            (a, b) => b.expenseDate.compareTo(a.expenseDate),
          );
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
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
      _fetchData();
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
      backgroundColor: const Color(0xffF7F7F7),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFEF3C7),
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

                const SizedBox(height: 28),

                /// FILTERS
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                _fetchData();
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

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
                            _fetchData();
                          }
                        },
                        child: dropdownBox(selectedMonth),
                      ),
                    ),

                    const SizedBox(width: 16),

                    InkWell(
                      onTap: _fetchData,
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xffE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            const SizedBox(width: 8),
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

                const SizedBox(height: 24),

                /// SUMMARY
                Row(
                  children: [
                    ExpenseSummaryCard(
                      title: "Total Expenses (MTD)",
                      amount:
                          "₹${dashboardData?.cards.totalExpensesMtd.toStringAsFixed(2) ?? "0.00"}",
                      icon: Icons.currency_rupee,
                      iconBg: const Color(0xffDBEAFE),

                      onTap: () {
                        showExpenseDetailsBottomSheet("Total Expenses (MTD)");
                      },
                    ),

                    const SizedBox(width: 16),

                    ExpenseSummaryCard(
                      title: "Salary / Payroll",
                      amount:
                          "₹${dashboardData?.cards.salaryPayroll.toStringAsFixed(2) ?? "0.00"}",
                      icon: Icons.person_outline,
                      iconBg: const Color(0xffDBEAFE),
                      onTap: () {
                        showExpenseDetailsBottomSheet("Salary / Payroll");
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    ExpenseSummaryCard(
                      title: "Rent & Facilities",
                      amount:
                          "₹${dashboardData?.cards.rentFacilities.toStringAsFixed(2) ?? "0.00"}",
                      icon: Icons.apartment,
                      iconBg: const Color(0xffEDE9FE),
                      onTap: () {
                        showExpenseDetailsBottomSheet("Rent");
                      },
                    ),

                    const SizedBox(width: 16),

                    ExpenseSummaryCard(
                      title: "Transport & Fuel",
                      amount:
                          "₹${dashboardData?.cards.transportFuel.toStringAsFixed(2) ?? "0.00"}",
                      icon: Icons.local_shipping_outlined,
                      iconBg: const Color(0xffDCFCE7),
                      onTap: () {
                        showExpenseDetailsBottomSheet("Transport");
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    ExpenseSummaryCard(
                      title: "Electricity",
                      amount:
                          "₹${_getCategoryAmount("ELECTRICITY").toStringAsFixed(2)}",
                      icon: Icons.bolt,
                      iconBg: const Color(0xffFEF3C7),
                      onTap: () {
                        showExpenseDetailsBottomSheet("Electricity");
                      },
                    ),

                    const SizedBox(width: 16),

                    ExpenseSummaryCard(
                      title: "Miscellaneous",
                      amount:
                          "₹${_getCategoryAmount("MISCELLANEOUS").toStringAsFixed(2)}",
                      icon: Icons.more_horiz,
                      iconBg: const Color(0xffF3F4F6),
                      onTap: () {
                        showExpenseDetailsBottomSheet("Miscellaneous");
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    ExpenseSummaryCard(
                      title: "Maintenance",
                      amount:
                          "₹${_getCategoryAmount("MAINTENANCE").toStringAsFixed(2)}",
                      icon: Icons.build,
                      iconBg: const Color(0xffFECACA),
                      onTap: () {
                        showExpenseDetailsBottomSheet("Maintenance");
                      },
                    ),

                    const SizedBox(width: 16),

                    ExpenseSummaryCard(
                      title: "Other Expenses",
                      amount:
                          "₹${_getCategoryAmount("OTHER_EXPENSES").toStringAsFixed(2)}",
                      icon: Icons.groups,
                      iconBg: const Color(0xffCCFBF1),
                      onTap: () {
                        showExpenseDetailsBottomSheet("Other_Expenses");
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// CATEGORY BREAKDOWN TABLE
                const Text(
                  "Category Breakdown",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.vertical(
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
                        ...dashboardData!.categories.map(
                          (cat) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade100),
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
                          dashboardData!.categories.isEmpty)
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

                const SizedBox(height: 32),

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

                      const SizedBox(height: 24),

                      const Text("Expense Date *"),

                      const SizedBox(height: 10),

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

                      const SizedBox(height: 20),

                      const Text("Expense Category *"),

                      const SizedBox(height: 10),

                      dropdownField(),

                      const SizedBox(height: 20),

                      const Text("Amount (₹) *"),

                      const SizedBox(height: 10),

                      ExpenseTextField(
                        hint: "e.g. 500",
                        controller: amountController,
                      ),

                      const SizedBox(height: 20),

                      const Text("Payment Method *"),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          paymentButton("Cash"),

                          const SizedBox(width: 14),

                          paymentButton("UPI"),

                          const SizedBox(width: 14),

                          paymentButton("Card"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text("Status"),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          statusButton("Paid"),

                          const SizedBox(width: 14),

                          statusButton("Pending"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text("Description"),

                      const SizedBox(height: 10),

                      ExpenseTextField(
                        hint: "e.g. Transport for stock from warehouse",
                        controller: descriptionController,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
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

                          const SizedBox(width: 16),

                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffFACC15),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: isSaving ? null : _saveExpense,
                                child: isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
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

                const SizedBox(height: 24),

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
                      const Text(
                        "Expense Categories",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 28),

                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),

                        mainAxisSpacing: 24,
                        crossAxisSpacing: 18,

                        childAspectRatio: 0.50,
                        children: [
                          InkWell(
                            onTap: () =>
                                setState(() => selectedCategory = "Rent"),
                            child: ExpenseCategoryItem(
                              title: "Rent",
                              icon: Icons.apartment,
                              bgColor: selectedCategory == "Rent"
                                  ? Colors.blue.shade100
                                  : const Color(0xffEDE9FE),
                            ),
                          ),

                          InkWell(
                            onTap: () =>
                                setState(() => selectedCategory = "Salary"),
                            child: ExpenseCategoryItem(
                              title: "Salary",
                              icon: Icons.person_outline,
                              bgColor: selectedCategory == "Salary"
                                  ? Colors.blue.shade100
                                  : const Color(0xffDBEAFE),
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
                                  ? Colors.blue.shade100
                                  : const Color(0xffFEF3C7),
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
                                  ? Colors.blue.shade100
                                  : const Color(0xffF3F4F6),
                            ),
                          ),

                          InkWell(
                            onTap: () =>
                                setState(() => selectedCategory = "Transport"),
                            child: ExpenseCategoryItem(
                              title: "Transport",
                              icon: Icons.local_shipping_outlined,
                              bgColor: selectedCategory == "Transport"
                                  ? Colors.blue.shade100
                                  : const Color(0xffDCFCE7),
                            ),
                          ),

                          InkWell(
                            onTap: () =>
                                setState(() => selectedCategory = "Packing"),
                            child: ExpenseCategoryItem(
                              title: "Packing",
                              icon: Icons.inventory_2,
                              bgColor: selectedCategory == "Packing"
                                  ? Colors.blue.shade100
                                  : const Color(0xffE9D5FF),
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
                                  ? Colors.blue.shade100
                                  : const Color(0xffFECACA),
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
                                  ? Colors.blue.shade100
                                  : const Color(0xffCCFBF1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

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
                      const Text(
                        "Recent Expenses",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const ExpenseTableHeader(),

                      const SizedBox(height: 30),

                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (dashboardData == null ||
                          dashboardData!.recentExpenses.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),

                              const SizedBox(height: 16),

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
                          itemCount: dashboardData!.recentExpenses.length,
                          itemBuilder: (context, index) {
                            return ExpenseTableRow(
                              expense: dashboardData!.recentExpenses[index],
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
      ),
    );
  }

  Widget dropdownBox(String title) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined),

          const SizedBox(width: 10),

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
          height: 56,
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
          height: 56,
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
              const SizedBox(height: 12),

              Container(
                width: 70,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 26),

              /// HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),

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

              const SizedBox(height: 24),

              /// TABLE
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),

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
                              width: 500,

                              child: Column(
                                children: [
                                  /// HEADER
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 14,
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
                  height: 58,

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
