abstract class DamageEvent {}

class FetchDamageCategoriesEvent extends DamageEvent {
  final int branchId;

  FetchDamageCategoriesEvent({
    required this.branchId,
  });
}
class SelectCategoryEvent extends DamageEvent {
  final String category;

  SelectCategoryEvent(this.category);
}
class FetchDamageHistoryEvent extends DamageEvent {
  final int branchId;

  FetchDamageHistoryEvent({required this.branchId});
}
class ReportDamageEvent extends DamageEvent {
  final int branchId;
  final String category;
  final String damagedEggs;

  ReportDamageEvent({
    required this.branchId,
    required this.category,
    required this.damagedEggs,
  });
}