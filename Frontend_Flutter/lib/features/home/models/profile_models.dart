class ProfileResponse {
  final String firstName;
  final String lastName;
  final String email;

  ProfileResponse({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String? newPassword;

  UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    this.newPassword,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'firstName': firstName, 'lastName': lastName};
    if (newPassword != null && newPassword!.isNotEmpty) {
      map['newPassword'] = newPassword;
    }
    return map;
  }
}
