import 'package:proteinova_connect/features/branch/damage_entry/data/model/damage_category_model.dart';
import 'package:proteinova_connect/features/branch/damage_entry/data/model/damage_history_model.dart';


class DamageState {
  final bool isLoading;
  final List<DamageCategoryModel> categories;
  final String? error;
  final String? selectedCategory;
  final List<DamageHistoryModel> history;
  final bool isSubmitting;
  
final bool isLoadingCategories;
final bool isLoadingHistory;
  const DamageState({
    this.isLoading = false,
    this.categories = const [],
    this.error,
    this.selectedCategory,
    this.history = const [],
    this.isSubmitting = false,
    this.isLoadingCategories=false,
    this.isLoadingHistory=false,

  });

  DamageState copyWith({
    bool? isLoading,
     bool? isLoadingCategories,
    bool? isLoadingHistory,
    List<DamageCategoryModel>? categories,
     String? selectedCategory,
    String? error,
    bool? isSubmitting,
    List<DamageHistoryModel>? history,
  }) {
    return DamageState(
      isLoading: isLoading ?? this.isLoading,
       isLoadingCategories:
          isLoadingCategories ?? this.isLoadingCategories,
      isLoadingHistory:
          isLoadingHistory ?? this.isLoadingHistory,
      categories: categories ?? this.categories,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      history: history ?? this.history,
       isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}