import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/addexpense/bloc/expense_bloc.dart';
import 'package:proteinova_connect/features/branch/expense_management/presentation/addexpense.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseManagement extends StatefulWidget {
  const ExpenseManagement({super.key});

  @override
  State<ExpenseManagement> createState() => _ExpenseManagementState();
}

class _ExpenseManagementState extends State<ExpenseManagement> {
  int? branchId;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  Future<void> _loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    branchId = prefs.getInt("branch_id");
    if (branchId != null) {
      context.read<ExpenseBloc>().add(FetchExpenses(branchId: branchId!));
    }
  }

  double _getTotal(List expenses) {
    double total = 0;
    for (var e in expenses) {
      total += double.tryParse(e.amount.toString()) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background1,
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is ExpenseSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            if (branchId != null) {
              context.read<ExpenseBloc>().add(FetchExpenses(branchId: branchId!));
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is ExpenseLoading || state is ExpenseInitial || state is ExpenseSubmitting;
          final expenses = state is ExpenseLoaded ? state.expenses : [];
          final total = _getTotal(expenses);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.07),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text("Expense Management", style: AppTextStyles.headingText22),
                    ],
                  ),
                   SizedBox(height:getHeight(context, 10)),
                  const Divider(),
                  if (isLoading) const LinearProgressIndicator(minHeight: 2),
                  SizedBox(height:getHeight(context, 10)),
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _expenseCard(
                          title: "Total Expense (MTD)",
                          value: "₹${total.toStringAsFixed(2)}",
                          icon: Icons.currency_rupee,
                        ),
                      ),
                     SizedBox(width:getWidth(context, 10)),
                      Expanded(
                        child: _expenseCard(
                          title: "Total Records",
                          value: "${expenses.length} entries",
                          icon: Icons.receipt_long,
                        ),
                      ),
                    ],
                  ),
                 SizedBox(height:getHeight(context, 15)),

                  // Add Expense Button
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Addexpense()),
                      );
                      if (result == true && branchId != null) {
                        context.read<ExpenseBloc>().add(FetchExpenses(branchId: branchId!));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.amber600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: AppColors.dark),
                          SizedBox(width:getWidth(context, 8)),
                          Text("Add Expense", style: AppTextStyles.headingText20),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height:getHeight(context, 15)),

                  // Category Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Expense Categories", style: AppTextStyles.headingText22),
                        SizedBox(height:getHeight(context, 10)),
                        const Divider(),
                       SizedBox(height:getHeight(context, 10)),
                        _buildCategoryGrid(),
                      ],
                    ),
                  ),

                  SizedBox(height:getHeight(context, 15)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Expenses", style: AppTextStyles.headingText20),
                      Text("View All", style: AppTextStyles.blueText2),
                    ],
                  ),

                  SizedBox(height:getHeight(context, 10)),

                  if (isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  else if (expenses.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("No Expenses Found"),
                      ),
                    )
                  else
                    ListView.builder(
                      itemCount: expenses.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = expenses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.category, style:AppTextStyles.bodyText16),
                                    Text("₹${item.amount}", style: AppTextStyles.bodyText16),
                                  ],
                                ),
                                SizedBox(height: getHeight(context, 8),),
                                Text(item.description),
                                 SizedBox(height: getHeight(context, 8),),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                     SizedBox(width: getWidth(context, 4),),
                                    Text(item.expenseDate, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                                SizedBox(height: getHeight(context, 8),),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Text(item.paymentMethod),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Text(item.status),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  SizedBox(height: getHeight(context, 20),),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _expenseCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE6EBF0), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: Colors.grey.shade700),
          ),
           SizedBox(width: getWidth(context, 10),),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                 SizedBox(height: getHeight(context, 4),),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {"icon": Icons.person, "title": "Salary"},
      {"icon": Icons.shopping_cart, "title": "Purchase"},
      {"icon": Icons.local_shipping, "title": "Transport"},
      {"icon": Icons.build, "title": "Maintenance"},
      {"icon": Icons.home, "title": "Rent"},
      {"icon": Icons.inventory_2, "title": "Packing"},
      {"icon": Icons.people, "title": "General"},
      {"icon": Icons.miscellaneous_services, "title": "Others"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cat["icon"] as IconData, color: Colors.grey.shade700),
               SizedBox(height: getHeight(context, 4),),
              Text(cat["title"] as String, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}