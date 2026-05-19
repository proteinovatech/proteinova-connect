class PurchaseDetailResponse {
  final int id;
  final String? supplierCompanyName;
  final String? supplierName;
  final String? phoneNumber;
  final String? createdAt;
  final String? warehouseLocation;
  final String? paymentMethod;
  final double? loadingCharge;
  final double? unloadingCharge;
  final double? transportCharge;
  final double? miscExpense;
  final double? paymentAmount;
  final double? debtAmount;
  final List<PurchaseDetailItem>? items;
  final List<PurchaseDetailExpense>? expenses;

  PurchaseDetailResponse({
    required this.id,
    this.supplierCompanyName,
    this.supplierName,
    this.phoneNumber,
    this.createdAt,
    this.warehouseLocation,
    this.paymentMethod,
    this.loadingCharge,
    this.unloadingCharge,
    this.transportCharge,
    this.miscExpense,
    this.paymentAmount,
    this.debtAmount,
    this.items,
    this.expenses,
  });

  factory PurchaseDetailResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List?;
    var expensesList = json['expenses'] as List?;

    return PurchaseDetailResponse(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      supplierCompanyName: json['supplier_company_name']?.toString(),
      supplierName: json['supplier_name']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      createdAt: json['created_at']?.toString(),
      warehouseLocation: json['warehouse_location']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      loadingCharge: json['loading_charge'] != null
          ? double.tryParse(json['loading_charge'].toString())
          : 0.0,
      unloadingCharge: json['unloading_charge'] != null
          ? double.tryParse(json['unloading_charge'].toString())
          : 0.0,
      transportCharge: json['transport_charge'] != null
          ? double.tryParse(json['transport_charge'].toString())
          : 0.0,
      miscExpense: json['misc_expense'] != null
          ? double.tryParse(json['misc_expense'].toString())
          : 0.0,
      paymentAmount: json['payment_amount'] != null
          ? double.tryParse(json['payment_amount'].toString())
          : 0.0,
      debtAmount: json['debt_amount'] != null
          ? double.tryParse(json['debt_amount'].toString())
          : 0.0,
      items: itemsList != null
          ? itemsList.map((i) => PurchaseDetailItem.fromJson(i)).toList()
          : null,
      expenses: expensesList != null
          ? expensesList.map((e) => PurchaseDetailExpense.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_company_name': supplierCompanyName,
      'supplier_name': supplierName,
      'phone_number': phoneNumber,
      'created_at': createdAt,
      'warehouse_location': warehouseLocation,
      'payment_method': paymentMethod,
      'loading_charge': loadingCharge,
      'unloading_charge': unloadingCharge,
      'transport_charge': transportCharge,
      'misc_expense': miscExpense,
      'payment_amount': paymentAmount,
      'debt_amount': debtAmount,
      'items': items?.map((e) => e.toJson()).toList(),
      'expenses': expenses?.map((e) => e.toJson()).toList(),
    };
  }
}

class PurchaseDetailItem {
  final String? eggCategoryGrade;
  final int? trays;
  final double? perEggPrice;
  final int? capacity;

  PurchaseDetailItem({
    this.eggCategoryGrade,
    this.trays,
    this.perEggPrice,
    this.capacity,
  });

  factory PurchaseDetailItem.fromJson(Map<String, dynamic> json) {
    return PurchaseDetailItem(
      eggCategoryGrade: json['egg_category_grade']?.toString(),
      trays: json['trays'] != null
          ? (json['trays'] is int
              ? json['trays'] as int
              : int.tryParse(json['trays'].toString()))
          : 0,
      perEggPrice: json['per_egg_price'] != null
          ? double.tryParse(json['per_egg_price'].toString())
          : 0.0,
      capacity: json['capacity'] != null
          ? (json['capacity'] is int
              ? json['capacity'] as int
              : int.tryParse(json['capacity'].toString()))
          : 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'egg_category_grade': eggCategoryGrade,
      'trays': trays,
      'per_egg_price': perEggPrice,
      'capacity': capacity,
    };
  }
}

class PurchaseDetailExpense {
  final String? expenseType;
  final double? amount;

  PurchaseDetailExpense({
    this.expenseType,
    this.amount,
  });

  factory PurchaseDetailExpense.fromJson(Map<String, dynamic> json) {
    return PurchaseDetailExpense(
      expenseType: json['expense_type']?.toString(),
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_type': expenseType,
      'amount': amount,
    };
  }
}
