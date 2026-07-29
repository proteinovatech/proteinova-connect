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
    final purchasesList =
        (purchaseResponse.data['data'] as List<dynamic>?) ?? [];

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
      int orders = int.tryParse(e["total_orders"]?.toString() ?? '0') ?? 0;

      double avgOrderValue = orders > 0 ? rev / orders : 0;
      double profit = rev - exp - pur;
      String margin = rev > 0
          ? "${((profit / rev) * 100).toStringAsFixed(1)}%"
          : "0%";
      double totalRevenue = 0;

      for (var item in branchSales) {
        totalRevenue +=
            double.tryParse(item["total_sales"]?.toString() ?? "0") ?? 0;
      }
      double progress = totalRevenue > 0 ? rev / totalRevenue : 0;

      print("Branch: $bName");
      print("Revenue: $rev");
      print("Orders: $orders");
      print("AvgOrderValue: $avgOrderValue");

      return {
        "branch_name": bName,
        "revenue": rev,
        "amount": rev,
        "progress": progress,
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
    for (var item in branchSales) {
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

        revenueByMonth[month] = (revenueByMonth[month] ?? 0) + amount;
      }
    }

    for (var purchase in purchasesList) {
      String date = purchase['date']?.toString() ?? '';

      if (date.isNotEmpty) {
        String month = DateFormat('MMM').format(DateTime.parse(date));

        double amount =
            double.tryParse(purchase['total_amount']?.toString() ?? '0') ?? 0;

        purchaseByMonth[month] = (purchaseByMonth[month] ?? 0) + amount;
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

    print("BRANCH SALES RESPONSE = ${response.data}");

    final branches = (response.data['branches'] as List<dynamic>?) ?? [];

    final trend = (response.data['trend'] as List<dynamic>?) ?? [];

    return {
      "branches": branches,
      "trend": trend,
      "transactions": [],

      // keep original response if needed
      "raw": response.data,
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
      double amount = double.tryParse(item['amount']?.toString() ?? '0') ?? 0;

      totalExpense += amount;

      String category = item['category']?.toString() ?? 'Other';
      categoryMap[category] = (categoryMap[category] ?? 0) + amount;
      if (category == 'TRANSPORT') {
        logisticsExpense += amount;
      }

      if (item['source'] == 'Purchase') {
        warehouseOps += amount;
      }
    }

    List<Map<String, dynamic>> categories = categoryMap.entries
        .map(
          (e) => {
            "name": e.key,
            "amount": e.value,
            "progress": totalExpense > 0 ? e.value / totalExpense : 0,
          },
        )
        .toList();

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    Map<String, double> dailyMap = {for (var day in days) day: 0};

    for (var item in list) {
      final date = DateTime.parse(item['date']);
      final day = DateFormat('EEE').format(date);

      dailyMap[day] =
          (dailyMap[day] ?? 0) +
          (double.tryParse(item['amount'].toString()) ?? 0);
    }

    final trendData = dailyMap.entries
        .map((e) => {'day': e.key, 'amount': e.value})
        .toList();
    print("CATEGORY MAP = $categoryMap");
    print("CATEGORIES = $categories");
    return {
      "stats": [
        {
          "title": "Total Expenses",
          "amount": "$totalExpense",
          "growth": "+4.4%",
          "icon": "money",
          "color": "red",
        },
        {
          "title": "Logistics & Transport",
          "amount": "$logisticsExpense",
          "growth": "-2.4%",
          "icon": "truck",
          "color": "blue",
        },
        {
          "title": "Warehouse Ops",
          "amount": "$warehouseOps",
          "growth": "+1.4%",
          "icon": "warehouse",
          "color": "orange",
        },
        {
          "title": "Pending Approvals",
          "amount": "14",
          "growth": "-",
          "icon": "check",
          "color": "grey",
        },
      ],
      "categories": categories,
      "dailyTrend": trendData,
      "recentExpenses": list
          .map(
            (e) => {
              "date": e["date"],
              "source": e["source"],
              "category": e["category"],
              "location": e["location"],
              "amount": e["amount"],
              "status": "Paid",
            },
          )
          .toList(),
    };
  }

  /// Purchase Report
  Future<Map<String, dynamic>> getPurchaseReport({
    String? startDate,
    String? endDate,
    bool useCompanyName = false,
  }) async {
    final response = await dio.get(
      '/api/reports/purchase',
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );

    final list = (response.data['data'] as List<dynamic>?) ?? [];
    print("RAW PURCHASE RESPONSE = ${response.data}");
    print("PURCHASE LIST = $list");

    double totalSpend = 0;
    int totalTrays = 0;
    Map<String, double> supplierMap = {};

    for (var item in list) {
      double amount =
          double.tryParse(item['total_amount']?.toString() ?? '0') ?? 0;

      int trays = int.tryParse(item['total_trays']?.toString() ?? '0') ?? 0;

      totalSpend += amount;
      totalTrays += trays;

      // Use company name instead of supplier_name
      final supplier = useCompanyName
          ? (item["supplier_company_name"] ?? "").toString().trim()
          : (item["supplier_name"] ?? "").toString().trim();

      if (supplier.isEmpty) continue;

      supplierMap[supplier] = (supplierMap[supplier] ?? 0) + amount;
    }

    List<Map<String, dynamic>> suppliers = supplierMap.entries
        .map(
          (e) => {
            "name": e.key,
            "amount": e.value,
            "progress": totalSpend > 0 ? e.value / totalSpend : 0,
          },
        )
        .toList();

    double avgCost = totalTrays > 0 ? totalSpend / totalTrays : 0;
    final activeSuppliers = list
        .map((e) {
          if (useCompanyName) {
            return (e["supplier_company_name"] ?? "").toString().trim();
          } else {
            return (e["supplier_name"] ?? "").toString().trim();
          }
        })
        .where((name) => name.isNotEmpty)
        .toSet()
        .length;

    Map<String, double> spendByMonth = {};
    Map<String, int> volumeByMonth = {};

    for (var item in list) {
      final dateStr = item["date"]?.toString();

      if (dateStr == null) continue;

      final month = DateFormat("MMM").format(DateTime.parse(dateStr));

      final amount =
          double.tryParse(item["total_amount"]?.toString() ?? "0") ?? 0;

      final trays = int.tryParse(item["total_trays"]?.toString() ?? "0") ?? 0;

      spendByMonth[month] = (spendByMonth[month] ?? 0) + amount;

      volumeByMonth[month] = (volumeByMonth[month] ?? 0) + trays;
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

    final spendBySupplier = suppliers.map((e) {
      return {
        "name": e["name"],
        "value": "₹ ${NumberFormat('#,##,##0', 'en_IN').format(e["amount"])}",
      };
    }).toList();

    final volumeBySupplier = supplierMap.entries.map((e) {
      final supplierRows = list.where((x) {
        final supplier = useCompanyName
            ? (x["supplier_company_name"] ?? "").toString().trim()
            : (x["supplier_name"] ?? "").toString().trim();

        return supplier == e.key;
      });

      int trays = 0;

      for (var row in supplierRows) {
        trays += int.tryParse(row["total_trays"].toString()) ?? 0;
      }

      return {"name": e.key, "value": trays};
    }).toList();

    Map<String, int> supplierCountMap = {};

    for (final item in list) {
      final supplier = useCompanyName
          ? (item["supplier_company_name"] ?? "").toString().trim()
          : (item["supplier_name"] ?? "").toString().trim();

      if (supplier.isEmpty) continue;

      supplierCountMap[supplier] = (supplierCountMap[supplier] ?? 0) + 1;
    }

    final supplierList = supplierCountMap.entries.map((e) {
      return {"name": e.key, "orders": e.value};
    }).toList();

    final totalOrdersList = list.map((e) {
      return {
        "name": e["supplier_name"] ?? "-",
        "value": "Order #${e["id"]}",
        "details": e["date"] != null
            ? DateFormat(
                "dd/MM/yyyy",
              ).format(DateTime.parse(e["date"].toString()))
            : "-",
      };
    }).toList();
    return {
      "stats": [
        {
          "title": "Total Spend",
          "amount": totalSpend.toStringAsFixed(0),
          "growth": "+4.4%",
          "icon": "money",
          "color": "blue",
        },
        {
          "title": "Total Volume (Units)",
          "amount": totalTrays.toString(),
          "growth": "+2.4%",
          "icon": "box",
          "color": "green",
        },
        {
          "title": "Avg Unit Cost",
          "amount": avgCost.toStringAsFixed(2),
          "growth": "+5.2%",
          "icon": "calculator",
          "color": "green",
        },
        {
          "title": "Active Suppliers",
          "amount": activeSuppliers.toString(),
          "growth": "-",
          "icon": "people",
          "color": "grey",
        },
      ],
      "suppliers": suppliers,
      "monthlySummary": list,
      "monthlyTrend": monthlyTrend,
      "spendBySupplier": spendBySupplier,
      "volumeBySupplier": volumeBySupplier,
      "supplierList": supplierList,

      "raw": list,
      "totalOrders": totalOrdersList,
    };
  }

  /// Warehouse Report
  Future<Map<String, dynamic>> getWarehouseReport({
    String? startDate,
    String? endDate,
    String? branchId,
  }) async {
    try {
      final response = await dio.get(
        '/api/reports/warehouse-dispatch',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
          'branchId': branchId,
        },
      );

      debugPrint("Warehouse API Response: ${response.data}");

      final list = (response.data['dispatches'] as List<dynamic>?) ?? [];
      Map<String, int> dayWiseDispatch = {};

      for (var item in list) {
        final date = DateTime.parse(item["date"]);

        final day = DateFormat('EEE').format(date);

        final eggs = (item["total_eggs"] as num?)?.toInt() ?? 0;

        dayWiseDispatch[day] = (dayWiseDispatch[day] ?? 0) + eggs;
      }
      List<Map<String, dynamic>> volumeChart = dayWiseDispatch.entries.map((e) {
        return {"day": e.key, "dispatched": e.value};
      }).toList();

      final availableStock = response.data['availableStock'] ?? 0;
      int totalTrays = 0;

      int totalEggs = 0;

      Set<String> drivers = {};

      int deliveredCount = 0;

      for (var item in list) {
        totalTrays += (item["total_trays"] as num?)?.toInt() ?? 0;
        totalEggs += (item["total_eggs"] as num?)?.toInt() ?? 0;

        if (item["driver_name"] != null) {
          drivers.add(item["driver_name"].toString());
        }

        if (item["status"]?.toString().toUpperCase() == "DELIVERED") {
          deliveredCount++;
        }
      }

      double onTimeDelivery = list.isEmpty
          ? 0
          : (deliveredCount / list.length) * 100;

      Map<String, int> destMap = {};

      for (var item in list) {
        int units = int.tryParse(item['total_eggs'].toString()) ?? 0;
        String dest = item['destination']?.toString() ?? "Unknown";

        destMap[dest] = (destMap[dest] ?? 0) + units;
      }

      List<Map<String, dynamic>> destinations = destMap.entries.map((e) {
        return {
          "name": e.key,
          "trays": e.value,
          "progress": totalEggs > 0 ? e.value / totalEggs : 0,
        };
      }).toList();

      return {
        "stats": [
          {
            "title": "Available Stock",
            "amount": availableStock.toString(),
            "growth": "",
            "icon": "warehouse",
            "color": "blue",
          },
          {
            "title": "Total Dispatched (Units)",
            "amount": NumberFormat.decimalPattern('en_IN').format(totalEggs),
            "growth": "",
            "icon": "truck",
            "color": "green",
          },
          {
            "title": "On-Time Delivery",
            "amount": "${onTimeDelivery.toStringAsFixed(0)}%",
            "growth": "",
            "icon": "check",
            "color": "orange",
          },
          {
            "title": "Active Drivers",
            "amount": drivers.length.toString(),
            "growth": "",
            "icon": "clock",
            "color": "grey",
          },
        ],

        "dispatchVolume": volumeChart,

        "destinations": destinations,

        "recentDispatches": list.map((e) {
          return {
            "date": e["date"] != null
                ? DateFormat('dd/MM/yyyy').format(DateTime.parse(e["date"]))
                : "",
            "dispatchId": "#DSP-${e["id"] ?? ""}",
            "destination": e["destination"] ?? "",
            "vehicle": e["vehicle_number"] ?? "",
            "quantity": (e["total_eggs"] as num?) ?? 0,
            "status": e["status"] ?? "",
          };
        }).toList(),
      };
    } on DioException catch (e) {
      debugPrint("STATUS CODE: ${e.response?.statusCode}");
      debugPrint("ERROR DATA: ${e.response?.data}");
      debugPrint("REQUEST URL: ${e.requestOptions.uri}");

      rethrow;
    }
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

    double totalExpense = categoryMap.values.fold(0, (a, b) => a + b);

    return categoryMap.entries
        .map(
          (e) => {
            "name": e.key,
            "amount": e.value,
            "progress": totalExpense > 0 ? e.value / totalExpense : 0,
          },
        )
        .toList();
  }
}
