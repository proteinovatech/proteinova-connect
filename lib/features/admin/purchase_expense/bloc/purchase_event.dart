import 'package:equatable/equatable.dart';

abstract class PurchaseExpenseEvent extends Equatable {
  const PurchaseExpenseEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial purchases + suppliers
class LoadPurchaseExpenseData extends PurchaseExpenseEvent {}

/// Load single purchase detail
class LoadPurchaseDetail extends PurchaseExpenseEvent {
  final int purchaseId;

  const LoadPurchaseDetail(this.purchaseId);

  @override
  List<Object?> get props => [purchaseId];
}

/// Save expense
class SaveExpenseEvent extends PurchaseExpenseEvent {
  final int purchaseId;
  final double loading;
  final double unloading;
  final double transport;

  const SaveExpenseEvent({
    required this.purchaseId,
    required this.loading,
    required this.unloading,
    required this.transport,
  });

  @override
  List<Object?> get props => [
        purchaseId,
        loading,
        unloading,
        transport,
      ];
}

/// Mark arrival
class MarkArrivalEvent extends PurchaseExpenseEvent {
  final int purchaseId;

  const MarkArrivalEvent(this.purchaseId);

  @override
  List<Object?> get props => [purchaseId];
}