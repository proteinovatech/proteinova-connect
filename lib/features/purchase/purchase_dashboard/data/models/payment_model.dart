class PaymentModel {
  final String id;
  String method;
  String amount;

  PaymentModel({
    required this.id,
    this.method = '',
    this.amount = '',
  });

  PaymentModel copyWith({
    String? id,
    String? method,
    String? amount,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      method: method ?? this.method,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'amount': amount,
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      method: json['method'] ?? '',
      amount: json['amount'] ?? '',
    );
  }
}