class ForgotPasswordResponse {
  final String? message;
  final bool isAuthenticated;

  ForgotPasswordResponse({this.message, required this.isAuthenticated});

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponse(
        message: json['message'],
        isAuthenticated: json['isAuthenticated'] ?? false,
      );
}
