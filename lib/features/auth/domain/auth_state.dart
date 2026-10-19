class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
  });

  String get displayName => (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : email;

  String get initials {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim().substring(0, 1).toUpperCase();
    }
    return email.isNotEmpty ? email.substring(0, 1).toUpperCase() : 'U';
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class AppAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final AppUser? user;
  final String? errorMessage;

  const AppAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  AppAuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AppUser? user,
    String? errorMessage,
  }) {
    return AppAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
