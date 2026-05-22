import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/settings/data/services/settings_service.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final SettingsService settingsService;

  UserBloc(this.settingsService) : super(UserInitial()) {

    /// FETCH USERS
    on<FetchUsersEvent>((event, emit) async {
      emit(UserLoading());

      try {
        final usersList = await settingsService.fetchUsersList();
        final formData = await settingsService.fetchUserFormData();

        emit(
          UserLoaded(
            users: usersList,
            formOptions: formData,
          ),
        );
      } catch (e) {
        emit(UserError("Error fetching data: $e"));
      }
    });

    /// SAVE USER
    on<SaveUserEvent>((event, emit) async {
      emit(UserLoading());

      try {
        final success = await settingsService.saveUser(
          event.userData,
          userId: event.userId,
        );

        if (success) {
          emit(
            UserActionSuccess(
              event.userId != null
                  ? "Staff member updated successfully"
                  : "Staff member added successfully",
            ),
          );

          /// Reload data
          final usersList = await settingsService.fetchUsersList();
          final formData = await settingsService.fetchUserFormData();

          emit(
            UserLoaded(
              users: usersList,
              formOptions: formData,
            ),
          );
        } else {
          emit(UserError("Failed to save user"));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    /// DELETE USER
    on<DeleteUserEvent>((event, emit) async {
      emit(UserLoading());

      try {
        final success =
            await settingsService.deleteUser(event.userId);

        if (success) {
          emit(
            UserActionSuccess(
              "Staff member deleted successfully",
            ),
          );

          final usersList = await settingsService.fetchUsersList();
          final formData = await settingsService.fetchUserFormData();

          emit(
            UserLoaded(
              users: usersList,
              formOptions: formData,
            ),
          );
        } else {
          emit(UserError("Failed to delete user"));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}