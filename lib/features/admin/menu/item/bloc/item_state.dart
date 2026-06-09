abstract class ItemState {}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemLoaded extends ItemState {
  final int plasticTrays;
  final int paperTrays;
  final int eggs;
  final List<dynamic> eggCategories;
  final List<dynamic> plasticTraysList;
  final List<dynamic> paperTraysList;
  final bool isSubmitting;

  ItemLoaded({
    required this.plasticTrays,
    required this.paperTrays,
    required this.eggs,
    required this.eggCategories,
    required this.plasticTraysList,
    required this.paperTraysList,
    this.isSubmitting = false,
  });
  
  ItemLoaded copyWith({
    int? plasticTrays,
    int? paperTrays,
    int? eggs,
    List<dynamic>? eggCategories,
    List<dynamic>? plasticTraysList,
    List<dynamic>? paperTraysList,
    bool? isSubmitting,
  }) {
    return ItemLoaded(
      plasticTrays: plasticTrays ?? this.plasticTrays,
      paperTrays: paperTrays ?? this.paperTrays,
      eggs: eggs ?? this.eggs,
      eggCategories: eggCategories ?? this.eggCategories,
      plasticTraysList: plasticTraysList ?? this.plasticTraysList,
      paperTraysList: paperTraysList ?? this.paperTraysList,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ItemError extends ItemState {
  final String message;

  ItemError(this.message);
}

class ItemSubmitLoading extends ItemState {}

class ItemSubmitSuccess extends ItemState {}

class ItemSubmitFailure extends ItemState {
  final String message;

  ItemSubmitFailure(this.message);
}
