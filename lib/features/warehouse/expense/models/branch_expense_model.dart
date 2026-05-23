import 'package:proteinova_connect/features/admin/expense/data/models/expense_model.dart';
<<<<<<< HEAD


=======
>>>>>>> 85d28b0e602cc9743218d922971a4602a9836de6


class BranchExpenseDashboardModel {
  final int branchId;
  final String? month;
  final ExpenseSummary cards;
  final List<ExpenseCategoryAmount> categories;
  final List<ExpenseModel> recentExpenses;

  BranchExpenseDashboardModel({
    required this.branchId,
    this.month,
    required this.cards,
    required this.categories,
    required this.recentExpenses,
  });

  factory BranchExpenseDashboardModel.fromJson(Map<String, dynamic> json) {
    return BranchExpenseDashboardModel(
      branchId: json['branch_id'] ?? 0,
      month: json['month'],
      cards: ExpenseSummary.fromJson(json['cards'] ?? {}),
      categories: (json['categories'] as List? ?? [])
          .map((e) => ExpenseCategoryAmount.fromJson(e))
          .toList(),
      recentExpenses: (json['recent_expenses'] as List? ?? [])
          .map((e) => ExpenseModel.fromJson(e))
          .toList(),
    );
  }
}

class ExpenseSummary {
  final double totalExpensesMtd;
  final double salaryPayroll;
  final double rentFacilities;
  final double transportFuel;

  ExpenseSummary({
    required this.totalExpensesMtd,
    required this.salaryPayroll,
    required this.rentFacilities,
    required this.transportFuel,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseSummary(
      totalExpensesMtd: (json['total_expenses_mtd'] ?? 0).toDouble(),
      salaryPayroll: (json['salary_payroll'] ?? 0).toDouble(),
      rentFacilities: (json['rent_facilities'] ?? 0).toDouble(),
      transportFuel: (json['transport_fuel'] ?? 0).toDouble(),
    );
  }
}

class ExpenseCategoryAmount {
  final String category;
  final double amount;

  ExpenseCategoryAmount({
    required this.category,
    required this.amount,
  });

  factory ExpenseCategoryAmount.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryAmount(
      category: json['category'] ?? "",
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}
