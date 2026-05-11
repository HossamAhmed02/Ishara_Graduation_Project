class LoginResponse {
  final bool isAuthenticated;
  final String token;
  final String refreshToken;
  final String email;
  final String? message;

  LoginResponse({
    required this.isAuthenticated,
    required this.token,
    required this.refreshToken,
    required this.email,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    isAuthenticated: json['isAuthenticated'] ?? false,
    token: json['token'] ?? '',
    refreshToken: json['refreshToken'] ?? '',
    email: json['email'] ?? '',
    message: json['message'],
  );
}
