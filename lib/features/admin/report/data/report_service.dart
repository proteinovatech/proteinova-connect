import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ReportService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['VITE_BACKEND_URL'] ?? '',

      headers: {'Content-Type': 'application/json'},
    ),
  );
  
  


  /// Financial Summary
  Future<Map<String, dynamic>> getFinancialSummary({
    String? startDate,
    String? endDate,
    String? branchId,
  }) async {
    final response = await dio.get(
      '/api/reports/financial-summary',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'branchId': branchId,
      },
    );
    
    final salesResponse = await dio.get(
      '/api/reports/branch-sales',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'branchId': branchId,
      },
    );

    final expenseResponse = await dio.get(
      '/api/reports/expense',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'branchId': branchId,
      },
    );

    final purchaseResponse = await dio.get(
      '/api/reports/purchase',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'branchId': branchId,
      },
    );
    debugPrint("FINANCIAL TYPE = ${response.data.runtimeType}");
debugPrint("SALES TYPE = ${salesResponse.data.runtimeType}");
debugPrint("EXPENSE TYPE = ${expenseResponse.data.runtimeType}");
debugPrint("PURCHASE TYPE = ${purchaseResponse.data.runtimeType}");

debugPrint("FINANCIAL DATA = ${response.data}");
debugPrint("SALES DATA = ${salesResponse.data}");
debugPrint("EXPENSE DATA = ${expenseResponse.data}");
debugPrint("PURCHASE DATA = ${purchaseResponse.data}");
    

    final summaryData = response.data;
    final branchSales =
    (salesResponse.data['branches'] as List<dynamic>?) ?? [];
    final expensesList = expenseResponse.data as List<dynamic>? ?? [];
    final purchasesList = purchaseResponse.data as List<dynamic>? ?? [];

    Map<String, double> branchExpenses = {};
    for (var exp in expensesList) {
      String bName = exp['branch_name']?.toString() ?? "Unknown";
      double amt = double.tryParse(exp['amount']?.toString() ?? '0') ?? 0;
      branchExpenses[bName] = (branchExpenses[bName] ?? 0) + amt;
    }

    Map<String, double> branchPurchases = {};
    for (var pur in purchasesList) {
      String bName = pur['branch_name']?.toString() ?? "Unknown";
      double amt = double.tryParse(pur['total_amount']?.toString() ?? '0') ?? 0;
      branchPurchases[bName] = (branchPurchases[bName] ?? 0) + amt;
    }

    List<Map<String, dynamic>> branches = branchSales.map((e) {
      String bName = e["branch_name"] ?? "Unknown";
      double rev = double.tryParse(e["total_sales"]?.toString() ?? '0') ?? 0;
      double exp = branchExpenses[bName] ?? 0;
      double pur = branchPurchases[bName] ?? 0;
      int orders =
      int.tryParse(e["total_orders"]?.toString() ?? '0') ?? 0;

  double avgOrderValue =
      orders > 0 ? rev / orders : 0;
      double profit = rev - exp - pur;
      String margin = rev > 0 ? "${((profit / rev) * 100).toStringAsFixed(1)}%" : "0%";
      double totalRevenue = 0;

for (var item in branchSales) {
  totalRevenue +=
      double.tryParse(item["total_sales"]?.toString() ?? "0") ?? 0;
}
double progress =
    totalRevenue > 0 ? rev / totalRevenue : 0;

       print("Branch: $bName");
  print("Revenue: $rev");
  print("Orders: $orders");
  print("AvgOrderValue: $avgOrderValue");

      return {
        "branch_name": bName,
        "revenue": rev,
        "amount": rev,
        "progress":progress, 
        "expenses": exp,
        "profit": profit,
         "avgOrderValue": avgOrderValue,
        "orders": orders,
        "branchName": bName,
        "purchases": pur,
        "margin": margin,
      };
    }).toList();

    int totalOrders = 0;
    for(var item in branchSales) {
       totalOrders += int.tryParse(item["total_orders"]?.toString() ?? '0') ?? 0;
    }

    Map<String, double> revenueByMonth = {};
Map<String, double> purchaseByMonth = {};

for (var sale in branchSales) {
  String date = sale['date']?.toString() ?? '';

  if (date.isNotEmpty) {
    String month = DateFormat('MMM').format(DateTime.parse(date));

    double amount =
        double.tryParse(sale['total_sales']?.toString() ?? '0') ?? 0;

    revenueByMonth[month] =
        (revenueByMonth[month] ?? 0) + amount;
  }
}

for (var purchase in purchasesList) {
  String date = purchase['date']?.toString() ?? '';

  if (date.isNotEmpty) {
    String month = DateFormat('MMM').format(DateTime.parse(date));

    double amount =
        double.tryParse(
          purchase['total_amount']?.toString() ?? '0',
        ) ??
        0;

    purchaseByMonth[month] =
        (purchaseByMonth[month] ?? 0) + amount;
  }
}
final months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

List<Map<String, dynamic>> chartData = months.map((month) {
  return {
    "month": month,
    "revenue": revenueByMonth[month] ?? 0,
    "purchase": purchaseByMonth[month] ?? 0,
  };
}).toList();

    return {
      "summary": {
        "totalRevenue": summaryData['revenue'] ?? 0,
        "totalExpenses": summaryData['totalExpenses'] ?? 0,
        "netProfit": summaryData['profit'] ?? 0,
        "totalOrders": totalOrders,
        "chartData": chartData,
        "branches": branches,
      },
      "topBranches": branches,
    };
  }

  /// Branch Sales Report
  Future<Map<String, dynamic>> getBranchSalesReport({
    String? startDate,
    String? endDate,
    String? branchId,
  }) async {
    final response = await dio.get(
      '/api/reports/branch-sales',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'branchId': branchId,
      },
    );

    final list = (response.data['branches'] as List<dynamic>?) ?? [];

    double totalSales = 0;
    int totalOrders = 0;
    for(var item in list) {
       totalSales += double.tryParse(item['total_sales']?.toString() ?? '0') ?? 0;
       totalOrders += int.tryParse(item['total_orders']?.toString() ?? '0') ?? 0;
    }

    return {
       "stats": [
          {"title": "Total Sales Revenue", "amount": totalSales.toStringAsFixed(0), "growth": "+8.4%", "icon": "money", "color": "blue"},
          {"title": "Total Units Sold", "amount": totalOrders.toString(), "growth": "+2.4%", "icon": "bag", "color": "green"},
          {"title": "Branch Stock Available", "amount": "68.3k", "growth": "-2.4%", "icon": "store", "color": "orange"},
          {"title": "Spoilage / Damaged Rate", "amount": "1.2%", "growth": "-0.5%", "icon": "warning", "color": "red"},
       ],
       "topItems": list.map((e) => {
          "name": e["branch_name"],
          "sales": e["total_sales"],
          "progress": 0.5,
       }).toList(),
       "hourlySales": [],
       "raw": list,
    };
  }

  /// Expense Report
  Future<Map<String, dynamic>> getExpenseReport({
    String? startDate,
    String? endDate,
    String? branchId,
  }) async {
    final response = await dio.get(
      '/api/reports/expense',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'branchId': branchId,
      },
    );

    final list = response.data as List<dynamic>? ?? [];

    double totalExpense = 0;
    double logisticsExpense = 0;
    double warehouseOps = 0;
    Map<String, double> categoryMap = {};
    for (var item in list) {
  double amount =
      double.tryParse(item['amount']?.toString() ?? '0') ?? 0;

  totalExpense += amount;

  String category = item['category']?.toString() ?? '';

  if (category == 'TRANSPORT') {
    logisticsExpense += amount;
  }

  if (item['source'] == 'Purchase') {
    warehouseOps += amount;
  }
}

    List<Map<String, dynamic>> categories = categoryMap.entries.map((e) => {
       "name": e.key,
       "amount": e.value,
       "progress": totalExpense > 0 ? e.value / totalExpense : 0,
    }).toList();
    

final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

Map<String, double> dailyMap = {
  for (var day in days) day: 0,
};

for (var item in list) {
  final date = DateTime.parse(item['date']);
  final day = DateFormat('EEE').format(date);

  dailyMap[day] =
      (dailyMap[day] ?? 0) +
      (double.tryParse(item['amount'].toString()) ?? 0);
}

final trendData = dailyMap.entries.map((e) => {
  'day': e.key,
  'amount': e.value,
}).toList();

    return {
       "stats": [
          {"title": "Total Expenses", "amount": "$totalExpense", "growth": "+4.4%", "icon": "money", "color": "red"},
          {"title": "Logistics & Transport", "amount": "$logisticsExpense", "growth": "-2.4%", "icon": "truck", "color": "blue"},
          {"title": "Warehouse Ops", "amount": "$warehouseOps", "growth": "+1.4%", "icon": "warehouse", "color": "orange"},
          {"title": "Pending Approvals", "amount": "14", "growth": "-", "icon": "check", "color": "grey"},
       ],
       "categories": categories,
       "dailyTrend": trendData,
       "recentExpenses": list.map((e) => {
          "date": e["date"],
  "source": e["source"],
  "category": e["category"],
  "location": e["location"],
  "amount": e["amount"],
  "status": "Paid",
       }).toList(),
    };
  }

  /// Purchase Report
  Future<Map<String, dynamic>> getPurchaseReport({
    String? startDate,
    String? endDate,
  }) async {
    final response = await dio.get(
      '/api/reports/purchase',
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );

    final list =response.data as List<dynamic>? ?? [];

    double totalSpend = 0;
    int totalTrays = 0;
    Map<String, double> supplierMap = {};

    for(var item in list) {
       double amount = double.tryParse(item['total_amount']?.toString() ?? '0') ?? 0;
       int trays = int.tryParse(item['total_trays']?.toString() ?? '0') ?? 0;
       totalSpend += amount;
       totalTrays += trays;
       String sup = item['supplier_name']?.toString() ?? 'Unknown';
       supplierMap[sup] = (supplierMap[sup] ?? 0) + amount;
    }

    List<Map<String, dynamic>> suppliers = supplierMap.entries.map((e) => {
       "name": e.key,
       "amount": e.value,
       "progress": totalSpend > 0 ? e.value / totalSpend : 0,
    }).toList();

    double avgCost = totalTrays > 0 ? totalSpend / totalTrays : 0;
    int activeSuppliers = supplierMap.length;


Map<String, double> spendByMonth = {};
Map<String, int> volumeByMonth = {};

for (var item in list) {
  final dateStr = item["date"]?.toString();

  if (dateStr == null) continue;

  final month = DateFormat("MMM").format(DateTime.parse(dateStr));

  final amount =
      double.tryParse(item["total_amount"]?.toString() ?? "0") ?? 0;

  final trays =
      int.tryParse(item["total_trays"]?.toString() ?? "0") ?? 0;

  spendByMonth[month] =
      (spendByMonth[month] ?? 0) + amount;

  volumeByMonth[month] =
      (volumeByMonth[month] ?? 0) + trays;
}
final months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

final monthlyTrend = months.map((month) {
  return {
    "month": month,
    "spend": spendByMonth[month] ?? 0,
    "volume": volumeByMonth[month] ?? 0,
  };
}).toList();

    return {
       "stats": [
          {"title": "Total Spend", "amount": totalSpend.toStringAsFixed(0), "growth": "+4.4%", "icon": "money", "color": "blue"},
          {"title": "Total Volume (Units)", "amount": totalTrays.toString(), "growth": "+2.4%", "icon": "box", "color": "green"},
          {"title": "Avg Unit Cost", "amount": avgCost.toStringAsFixed(2), "growth": "-1.4%", "icon": "calculator", "color": "orange"},
          {"title": "Active Suppliers", "amount": activeSuppliers.toString(), "growth": "-", "icon": "people", "color": "grey"},
       ],
       "suppliers": suppliers,
       "monthlySummary": list,
       "monthlyTrend":monthlyTrend,
       "raw": list,
    };
  }

  /// Warehouse Report
  Future<Map<String, dynamic>> getWarehouseReport({
    String? startDate,
    String? endDate,
    String? branchId,
  }) async {
    final response = await dio.get(
      '/api/reports/warehouse-dispatch',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'branchId': branchId,
      },
    );

    final list = (response.data['branches'] as List<dynamic>?) ?? [];

    int totalTrays = 0;
    Map<String, int> destMap = {};

    for(var item in list) {
       int trays = int.tryParse(item['total_trays']?.toString() ?? '0') ?? 0;
       totalTrays += trays;
       String dest = item['destination']?.toString() ?? 'Unknown';
       destMap[dest] = (destMap[dest] ?? 0) + trays;
    }

    List<Map<String, dynamic>> destinations = destMap.entries.map((e) => {
       "name": e.key,
       "trays": e.value,
       "progress": totalTrays > 0 ? e.value / totalTrays : 0,
    }).toList();

    return {
       "stats": [
          {"title": "Available Stock", "amount": "420.3K", "growth": "+4.4%", "icon": "warehouse", "color": "blue"},
          {"title": "Total Dispatched (Units)", "amount": totalTrays >= 1000 ? "${(totalTrays/1000).toStringAsFixed(1)}K" : totalTrays.toString(), "growth": "+12.4%", "icon": "truck", "color": "green"},
          {"title": "On-Time Delivery", "amount": "94.5%", "growth": "-1.4%", "icon": "check", "color": "orange"},
          {"title": "Active Suppliers", "amount": "14", "growth": "- 15m", "icon": "clock", "color": "grey"},
       ],
       "destinations": destinations,
       "recentDispatches": list.map((e) => {
          "id": e["id"]?.toString() ?? "",
          "destination": e["destination"],
          "date": e["date"],
          "trays": e["total_trays"],
          "status": e["status"],
       }).toList(),
    };
  }

  /// Branch List
  Future<List<dynamic>> getBranches() async {
    final response = await dio.get('/api/branches');

    return response.data['data'] ?? [];
  }
    Future<List<Map<String, dynamic>>> getCategories() async {
  Map<String, double> categoryMap = {
    "Transport": 49070,
    "Loading": 5400,
    "Unloading": 4000,
  };

  double totalExpense =
      categoryMap.values.fold(0, (a, b) => a + b);

  return categoryMap.entries.map((e) => {
    "name": e.key,
    "amount": e.value,
    "progress": totalExpense > 0 ? e.value / totalExpense : 0,
  }).toList();
}
} 

