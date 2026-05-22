class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final int? userId;
  final String email;
  final String role;
  final String? successMessage;
  final String? errorMessage;

  ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.userId,
    this.email = '',
    this.role = '',
    this.successMessage,
    this.errorMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    int? userId,
    String? email,
    String? role,
    String? successMessage,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}