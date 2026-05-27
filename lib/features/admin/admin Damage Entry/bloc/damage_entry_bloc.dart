import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/models/damage_location_model.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/models/damage_category_model.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/models/damage_history_model.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/repository/damage_entry_service.dart';

part 'damage_entry_event.dart';
part 'damage_entry_state.dart';

class DamageEntryBloc extends Bloc<DamageEntryEvent, DamageEntryState> {
  DamageEntryBloc() : super(DamageEntryInitial()) {
    on<FetchLocationsEvent>((event, emit) async {
      emit(DamageLocationsLoading());
      try {
        final locations = await DamageEntryService.getLocations();
        emit(DamageLocationsLoaded(locations: locations));
      } catch (e) {
        emit(DamageEntryError(message: 'Failed to fetch locations: $e'));
      }
    });

    on<LocationSelectedEvent>((event, emit) async {
      final loc = event.location;
      List<DamageLocation> currentLocations = [];

      if (state is DamageLocationsLoaded) {
        currentLocations = (state as DamageLocationsLoaded).locations;
      } else if (state is DamageDataLoaded) {
        currentLocations = (state as DamageDataLoaded).locations;
      } else if (state is DamageEntryError) {
        currentLocations = (state as DamageEntryError).locations;
      }

      if (loc == null) {
        emit(DamageLocationsLoaded(locations: currentLocations));
        return;
      }

      emit(DamageDataLoading(locations: currentLocations, selectedLocation: loc));

      try {
        final results = await Future.wait([
          DamageEntryService.getCategories(locationType: loc.type, locationName: loc.name),
          DamageEntryService.getHistory(locationType: loc.type, locationName: loc.name),
        ]);

        final categories = results[0] as List<DamageCategory>;
        final history = results[1] as List<DamageHistory>;

        emit(DamageDataLoaded(
          locations: currentLocations,
          selectedLocation: loc,
          categories: categories,
          history: history,
        ));
      } catch (e) {
        emit(DamageEntryError(
          message: 'Failed to fetch location data: $e',
          locations: currentLocations,
          selectedLocation: loc,
        ));
      }
    });

    on<SubmitDamageReportEvent>((event, emit) async {
      List<DamageLocation> locations = [];
      DamageLocation selectedLocation = event.location;
      List<DamageCategory> categories = [];
      List<DamageHistory> history = [];

      if (state is DamageDataLoaded) {
        final s = state as DamageDataLoaded;
        locations = s.locations;
        categories = s.categories;
        history = s.history;
      } else if (state is DamageReportingSuccess) {
        final s = state as DamageReportingSuccess;
        locations = s.locations;
        categories = s.categories;
        history = s.history;
      }

      emit(DamageReportingProgress(
        locations: locations,
        selectedLocation: selectedLocation,
        categories: categories,
        history: history,
      ));

      try {
        final response = await DamageEntryService.reportDamage(
          locationType: selectedLocation.type,
          locationName: selectedLocation.name,
          category: event.category,
          damagedEggs: event.damagedEggs,
        );

        final String successMessage = response['message'] ?? 'Damage reported successfully';

        // Fetch refreshed categories and history
        final results = await Future.wait([
          DamageEntryService.getCategories(
            locationType: selectedLocation.type,
            locationName: selectedLocation.name,
          ),
          DamageEntryService.getHistory(
            locationType: selectedLocation.type,
            locationName: selectedLocation.name,
          ),
        ]);

        final updatedCategories = results[0] as List<DamageCategory>;
        final updatedHistory = results[1] as List<DamageHistory>;

        emit(DamageReportingSuccess(
          locations: locations,
          selectedLocation: selectedLocation,
          categories: updatedCategories,
          history: updatedHistory,
          message: successMessage,
        ));
      } catch (e) {
        emit(DamageEntryError(
          message: 'Failed to report damage: $e',
          locations: locations,
          selectedLocation: selectedLocation,
          categories: categories,
          history: history,
        ));
      }
    });
  }
}
