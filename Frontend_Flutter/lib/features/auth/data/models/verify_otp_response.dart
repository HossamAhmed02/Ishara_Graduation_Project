class VerifyOtpResponse {
  final String? message;
  final bool isAuthenticated;

  VerifyOtpResponse({this.message, required this.isAuthenticated});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        message: json['message'],
        isAuthenticated: json['isAuthenticated'] ?? false,
      );
}
