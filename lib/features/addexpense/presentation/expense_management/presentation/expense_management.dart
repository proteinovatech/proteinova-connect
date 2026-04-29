import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/addexpense/presentation/addexpense.dart';
import 'package:proteinova_connect/features/addexpense/presentation/expense_management/widget/expense_category.dart';
import 'package:proteinova_connect/features/addexpense/presentation/expense_management/widget/expensecard.dart';
import 'package:proteinova_connect/features/addexpense/presentation/expense_management/widget/expensemodel_data.dart';
import 'package:proteinova_connect/features/addexpense/presentation/expense_management/widget/expenses.dart';

class ExpenseManagement extends StatefulWidget {
  const ExpenseManagement({super.key});

  @override
  State<ExpenseManagement> createState() => _ExpenseManagementState();
}

class _ExpenseManagementState extends State<ExpenseManagement> {
   bool isExpanded = true;
  @override
  Widget build(BuildContext context) {
         final Size size =MediaQuery.of(context).size;
    return Scaffold(
       backgroundColor: AppColors.background1,
           body: Padding(padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: size.height * 0.07),

      Row(
        children: [
         IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ), 
          Text(
            "Expense Management",
            style: AppTextStyles.headingText22,
          ),
        ],
      ),

      const SizedBox(height: 10),
Divider(),
SizedBox(height: 10),
      Row(
        children: const [
          Expanded(
            child: Expenses(
              title: "Total Expense(MTD)",
              value: "\$24,850.00",
              icon: Icons.currency_pound,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Expenses(
              title: "Salary Payroll",
              value: "\$12,400.00",
              icon: Icons.person,
              subtitle: "- Unchanged",
            ),
          ),
        ],
      ),

      const SizedBox(height: 10),

      Row(
        children: const [
          Expanded(
            child: Expenses(
              title: "Rent & Facilities",
              value: "\$5,800.00",
              icon: Icons.inventory,
               subtitle: "- Unchanged",
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Expenses(
              title: "Transport & Fuel",
              value: "\$4,120.00",
              icon: Icons.local_shipping,
             
            ),
          ),
        ],
      ),
      SizedBox(height: 15,),
      GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Addexpense(),
      ),
    );
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
        const SizedBox(width: 8),
        Text(
          "Add Expense",
          style: AppTextStyles.headingText20,
        ),
      ],
    ),
  ),
),
SizedBox(height: 10,),
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
      Text(
        "Expense Category",
        style: AppTextStyles.headingText22,
      ),
      const SizedBox(height: 10),
      const Divider(),
      SizedBox(height: 10,),
Column(
  children: [
       Row(
      children: const [
        Expanded(child: ExpenseCategory(icon: Icons.person, title: "Salary")),
        SizedBox(width: 10),
        Expanded(child: ExpenseCategory(icon: Icons.shopping_cart, title: "Purchase")),
        SizedBox(width: 10),
        Expanded(child: ExpenseCategory(icon: Icons.local_shipping, title: "Transport")),
      ],
    ),
    const SizedBox(height: 10),
    Row(
      children: const [
        Expanded(child: ExpenseCategory(icon: Icons.people, title: "Maintanace")),
        SizedBox(width: 10),
        Expanded(child: ExpenseCategory(icon: Icons.home, title: "Rent")),
        SizedBox(width: 10),
        Expanded(child: ExpenseCategory(icon: Icons.people, title: "Packing")),
      ],
    ),
    const SizedBox(height: 10),
    Row(
      children: const [
        Spacer(),
        Expanded(child: ExpenseCategory(icon: Icons.people, title: "General")),
        SizedBox(width: 10),
        Expanded(child: ExpenseCategory(icon: Icons.miscellaneous_services, title: "Others")),
        Spacer(),
      ],
    ),
  ],
)
    ],
  ),
),
SizedBox(height: 15,),
 Row(
   mainAxisAlignment: MainAxisAlignment.spaceBetween,
   children: [
     const Text(
       "Recent Expenses",
       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
     ),
     Text("View All",style: AppTextStyles.blueText2,)
           ],
         ),
            
          ListView.builder(
            itemCount: expenses.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ExpenseCard(item: expenses[index]);
            },
          ),
                const SizedBox(height: 20),
    ],
  ),
))
    );
  }
}
