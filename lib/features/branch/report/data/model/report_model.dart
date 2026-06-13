class ReportData {
  final double totalRevenue;
  final double totalExpenses;
  final int totalSalesOrders;
  final double totalPendingCollection;
  final int totalTraysReturned;
  
  // Breakdown lists
  final List<CategorySale> categorySales;
  final List<ExpenseCategory> expenseCategories;

  ReportData({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalSalesOrders,
    required this.totalPendingCollection,
    required this.totalTraysReturned,
    required this.categorySales,
    required this.expenseCategories,
  });

  double get netProfit => totalRevenue - totalExpenses;

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      totalExpenses: double.tryParse(json['total_expenses']?.toString() ?? '0') ?? 0.0,
      totalSalesOrders: json['total_sales_orders'] ?? 0,
      totalPendingCollection: double.tryParse(json['total_pending_collection']?.toString() ?? '0') ?? 0.0,
      totalTraysReturned: json['total_trays_returned'] ?? 0,
      categorySales: (json['category_sales'] as List<dynamic>?)
              ?.map((e) => CategorySale.fromJson(e))
              .toList() ??
          [],
      expenseCategories: (json['expense_categories'] as List<dynamic>?)
              ?.map((e) => ExpenseCategory.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CategorySale {
  final String name;
  final double amount;
  final int quantity;

  CategorySale({required this.name, required this.amount, required this.quantity});

  factory CategorySale.fromJson(Map<String, dynamic> json) {
    return CategorySale(
      name: json['name'] ?? 'Unknown',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 0,
    );
  }
}

class ExpenseCategory {
  final String name;
  final double amount;

  ExpenseCategory({required this.name, required this.amount});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      name: json['name'] ?? 'Unknown',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}
