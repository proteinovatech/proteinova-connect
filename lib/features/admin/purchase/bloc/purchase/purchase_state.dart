abstract class PurchaseState {}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}



class PurchaseError extends PurchaseState {
  final String message;

  PurchaseError(this.message);
}
class PurchaseLoaded extends PurchaseState {
  final List<dynamic>allPurchases;
  final List<dynamic>? suppliers;
  final List<dynamic> purchases;
  final String?message;

  PurchaseLoaded({
    required this.allPurchases,
     this.suppliers,
    required this.purchases,
    this.message
  });
}
class PurchaseSubmitting extends PurchaseState {}

class PurchaseSubmitSuccess extends PurchaseState {}

class PurchaseSubmitFailure extends PurchaseState {
  final String message;

  PurchaseSubmitFailure(this.message);
}
