import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/settings/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_event.dart';
import 'profile_state.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SettingsService settingsService;

  ProfileBloc(this.settingsService) : super(ProfileState()) {

    /// LOAD PROFILE
    on<LoadProfileEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        final prefs = await SharedPreferences.getInstance();

        final userId = prefs.getInt('userId');
        final email = prefs.getString('email') ?? '';
        final role = prefs.getString('role') ?? '';

        emit(
          state.copyWith(
            isLoading: false,
            userId: userId,
            email: email,
            role: role.toUpperCase(),
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    /// SAVE PROFILE
    on<SaveProfileEvent>((event, emit) async {

      if (state.userId == null) {
        emit(
          state.copyWith(
            errorMessage: "User ID not found",
          ),
        );
        return;
      }

      emit(state.copyWith(isSaving: true));

      try {
        final success = await settingsService.updateProfile(
          state.userId!,
          {
            "email": event.email,
            "role": event.role.toLowerCase(),
            "password": event.password,
          },
        );

        if (success) {

          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('email', event.email);

          emit(
            state.copyWith(
              isSaving: false,
              email: event.email,
              successMessage: "Profile updated successfully!",
            ),
          );
        } else {
          emit(
            state.copyWith(
              isSaving: false,
              errorMessage: "Failed to update profile",
            ),
          );
        }
      } catch (e) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}