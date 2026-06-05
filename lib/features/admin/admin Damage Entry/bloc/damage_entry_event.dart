part of 'damage_entry_bloc.dart';

abstract class DamageEntryEvent {}

class FetchLocationsEvent extends DamageEntryEvent {}

class LocationSelectedEvent extends DamageEntryEvent {
  final DamageLocation? location;

  LocationSelectedEvent(this.location);
}

class SubmitDamageReportEvent extends DamageEntryEvent {
  final DamageLocation location;
  final String category;
  final int damagedEggs;

  SubmitDamageReportEvent({
    required this.location,
    required this.category,
    required this.damagedEggs,
  });
}
