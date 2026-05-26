import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/damage_entry/data/repository/damage_repository.dart';

import 'damage_event.dart';
import 'damage_state.dart';


class DamageBloc extends Bloc<DamageEvent, DamageState> {

  final DamageRepository repository;

  DamageBloc(this.repository)
      : super(const DamageState()) {

    on<FetchDamageCategoriesEvent>(_fetchCategories);
     on<SelectCategoryEvent>((event, emit) {
      emit(state.copyWith(selectedCategory: event.category));
    });
    on<FetchDamageHistoryEvent>((event, emit) async {

  emit(state.copyWith(isLoadingHistory: true));

  try {
    final history = await repository.getDamageHistory(
      branchId: event.branchId,
    );

    emit(state.copyWith(
      isLoading: false,
      history: history,
    ));

  } catch (e) {
    emit(state.copyWith(
      isLoading: false,
      error: e.toString(),
    ));
  }
});
on<ReportDamageEvent>((event, emit) async {
  emit(state.copyWith(isSubmitting: true, error: null));

  try {
    await repository.reportDamage(
      branchId: event.branchId,
      category: event.category,
      damagedEggs: event.damagedEggs,
    );

    emit(state.copyWith(isSubmitting: false));

    // 🔥 refresh history correctly
    final history = await repository.getDamageHistory(
      branchId: event.branchId,
    );

    emit(state.copyWith(history: history));

  } catch (e) {
    emit(state.copyWith(
      isSubmitting: false,
      error: e.toString(),
    ));
  }
});
  }
  
  Future<void> _fetchCategories(
  FetchDamageCategoriesEvent event,
  Emitter<DamageState> emit,
) async {
  emit(state.copyWith(isLoadingHistory: true));

  try {
    final categories = await repository.getDamageCategories(
      branchId: event.branchId,
    );

    emit(
      state.copyWith(
        isLoading: false,
        categories: categories,
        selectedCategory: categories.isNotEmpty
            ? categories.first.eggCategoryGrade
            : null,
      ),
    );
  } catch (e) {
    emit(
      state.copyWith(
        isLoading: false,
        error: e.toString(),
      ),
    );
  }
}
  
}