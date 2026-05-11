class ResetPasswordRequest {
  final String email;
  final String newPassword;
  final String token;

  ResetPasswordRequest({
    required this.email,
    required this.newPassword,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'newPassword': newPassword,
    'token': token,
  };
}
