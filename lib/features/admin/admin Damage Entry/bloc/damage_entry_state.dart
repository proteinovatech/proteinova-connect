part of 'damage_entry_bloc.dart';

abstract class DamageEntryState {}

class DamageEntryInitial extends DamageEntryState {}

class DamageLocationsLoading extends DamageEntryState {}

class DamageLocationsLoaded extends DamageEntryState {
  final List<DamageLocation> locations;

  DamageLocationsLoaded({required this.locations});
}

class DamageDataLoading extends DamageEntryState {
  final List<DamageLocation> locations;
  final DamageLocation selectedLocation;

  DamageDataLoading({
    required this.locations,
    required this.selectedLocation,
  });
}

class DamageDataLoaded extends DamageEntryState {
  final List<DamageLocation> locations;
  final DamageLocation selectedLocation;
  final List<DamageCategory> categories;
  final List<DamageHistory> history;

  DamageDataLoaded({
    required this.locations,
    required this.selectedLocation,
    required this.categories,
    required this.history,
  });
}

class DamageReportingProgress extends DamageEntryState {
  final List<DamageLocation> locations;
  final DamageLocation selectedLocation;
  final List<DamageCategory> categories;
  final List<DamageHistory> history;

  DamageReportingProgress({
    required this.locations,
    required this.selectedLocation,
    required this.categories,
    required this.history,
  });
}

class DamageReportingSuccess extends DamageEntryState {
  final List<DamageLocation> locations;
  final DamageLocation selectedLocation;
  final List<DamageCategory> categories;
  final List<DamageHistory> history;
  final String message;

  DamageReportingSuccess({
    required this.locations,
    required this.selectedLocation,
    required this.categories,
    required this.history,
    required this.message,
  });
}

class DamageEntryError extends DamageEntryState {
  final String message;
  final List<DamageLocation> locations;
  final DamageLocation? selectedLocation;
  final List<DamageCategory> categories;
  final List<DamageHistory> history;

  DamageEntryError({
    required this.message,
    this.locations = const [],
    this.selectedLocation,
    this.categories = const [],
    this.history = const [],
  });
}
