class ResetPasswordResponse {
  final String? message;
  final bool isAuthenticated;

  ResetPasswordResponse({this.message, required this.isAuthenticated});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ResetPasswordResponse(
        message: json['message'],
        isAuthenticated: json['isAuthenticated'] ?? false,
      );
}
