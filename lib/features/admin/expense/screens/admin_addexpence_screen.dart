import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/admin/expense/data/repository/expense_repository.dart';
import 'package:proteinova_connect/features/admin/expense/widgets/expense_textfield.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/add_expense_shimmer.dart';

class AdminAddExpenseScreen extends StatefulWidget {
  const AdminAddExpenseScreen({super.key});

  @override
  State<AdminAddExpenseScreen> createState() => _AdminAddExpenseScreenState();
}

class _AdminAddExpenseScreenState extends State<AdminAddExpenseScreen> {
  final ExpenseRepository _repository = ExpenseRepository();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String selectedCategory = "Transport";
  String selectedPayment = "CASH";
  String selectedStatus = "PAID";
  bool isSaving = false;
  bool isLoadingBranches = true;

  Map<int, String> branches = {};
  int? selectedLocationId;

  final List<String> categories = [
    "Transport",
    "Rent",
    "Salary",
    "Electricity",
    "Miscellaneous",
    "Packing",
    "Maintenance",
    "Other Expenses",
  ];

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      final fetchedBranches = await _repository.fetchBranches();
      if (mounted) {
        setState(() {
          branches = fetchedBranches;
          if (branches.isNotEmpty) {
            selectedLocationId = branches.keys.first;
          }
          isLoadingBranches = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingBranches = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching locations: $e")));
      }
    }
  }

  Future<void> _saveExpense() async {
    if (selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location first")),
      );
      return;
    }
    if (amountController.text.isEmpty ||
        double.tryParse(amountController.text) == null ||
        double.parse(amountController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount greater than 0"),
        ),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      await _repository.createBranchExpense(
        branchId: selectedLocationId!,
        expenseDate: dateController.text,
        category: selectedCategory.toUpperCase().replaceAll(' ', '_'),
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
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color selectedColor = Colors.blue,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? selectedColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? selectedColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? selectedColor : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isSelected ? selectedColor : Colors.black87,
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
    return Scaffold(
      backgroundColor: const Color(
        0xffF8F9FE,
      ), // Light background like in image
      appBar: AppBar(
        backgroundColor: const Color(0xffF8F9FE),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Expense",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body:isLoadingBranches
    ? const AddExpenseShimmer()
    : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    _buildLabel("Location", isRequired: true),
                    
                    
                      Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xffE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.store_outlined,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value:
                                      branches.containsKey(selectedLocationId)
                                      ? selectedLocationId
                                      : null,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  hint: const Text("Select Location"),
                                  items: branches.entries.map((entry) {
                                    return DropdownMenuItem<int>(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedLocationId = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Expense Date
                    _buildLabel("Expense Date", isRequired: true),
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
                            dateController.text = DateFormat(
                              'yyyy-MM-dd',
                            ).format(picked);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: ExpenseTextField(
                          hint: "YYYY-MM-DD",
                          controller: dateController,
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Expense Category
                    _buildLabel("Expense Category", isRequired: true),
                    Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: categories.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedCategory = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amount
                    _buildLabel("Amount (₹)", isRequired: true),
                    ExpenseTextField(
                      hint: "e.g. 500",
                      controller: amountController,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.currency_rupee,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Method
                    _buildLabel("Payment Method", isRequired: true),
                    Row(
                      children: [
                        _buildOptionButton(
                          label: "CASH",
                          isSelected: selectedPayment == "CASH",
                          icon: Icons.account_balance_wallet_outlined,
                          onTap: () => setState(() => selectedPayment = "CASH"),
                        ),
                        const SizedBox(width: 10),
                        _buildOptionButton(
                          label: "UPI",
                          isSelected: selectedPayment == "UPI",
                          icon: Icons.qr_code_scanner,
                          selectedColor: Colors.deepPurple,
                          onTap: () => setState(() => selectedPayment = "UPI"),
                        ),
                        const SizedBox(width: 10),
                        _buildOptionButton(
                          label: "CARD",
                          isSelected: selectedPayment == "CARD",
                          icon: Icons.credit_card,
                          selectedColor: Colors.green,
                          onTap: () => setState(() => selectedPayment = "CARD"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Status
                    _buildLabel("Status"),
                    Row(
                      children: [
                        _buildOptionButton(
                          label: "PAID",
                          isSelected: selectedStatus == "PAID",
                          icon: Icons.check_circle_outline,
                          onTap: () => setState(() => selectedStatus = "PAID"),
                        ),
                        const SizedBox(width: 10),
                        _buildOptionButton(
                          label: "PENDING",
                          isSelected: selectedStatus == "PENDING",
                          icon: Icons.access_time,
                          selectedColor: Colors.orange,
                          onTap: () =>
                              setState(() => selectedStatus = "PENDING"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    _buildLabel("Description"),
                    ExpenseTextField(
                      hint: "e.g. Transport for stock from warehouse",
                      controller: descriptionController,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffF3F4F6),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      amountController.clear();
                      descriptionController.clear();
                      setState(() {
                        selectedCategory = "Transport";
                        selectedPayment = "CASH";
                        selectedStatus = "PAID";
                        dateController.text = DateFormat(
                          'dd-MM-yyyy',
                        ).format(DateTime.now());
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Reset",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
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
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Save Expense",
                                style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

}
