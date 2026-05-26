class ExpenseModel {
  final int id;
  final int branchId;
  final String expenseDate;
  final String category;
  final String amount;
  final String paymentMethod;
  final String description;
  final String status;
  final String? attachmentUrl;
  final int? createdBy;
  final String? createdAt;

  ExpenseModel({
    required this.id,
    required this.branchId,
    required this.expenseDate,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.description,
    required this.status,
    this.attachmentUrl,
    this.createdBy,
    this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json["id"] ?? 0,
      branchId: json["branch_id"] ?? 0,
      expenseDate: json["expense_date"] ?? "",
      category: json["category"] ?? "",
      amount: json["amount"].toString(),
      paymentMethod: json["payment_method"] ?? "",
      description: json["description"] ?? "",
      status: json["status"] ?? "",
      attachmentUrl: json["attachment_url"],
      createdBy: json["created_by"],
      createdAt: json["created_at"],
    );
  }
}