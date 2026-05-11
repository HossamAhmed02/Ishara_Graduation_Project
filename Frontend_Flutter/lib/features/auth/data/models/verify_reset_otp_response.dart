class VerifyResetOtpResponse {
  final String? message;
  final bool isAuthenticated;
  final String? resetToken;

  VerifyResetOtpResponse({
    this.message,
    required this.isAuthenticated,
    this.resetToken,
  });

  factory VerifyResetOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyResetOtpResponse(
        message: json['message'],
        isAuthenticated: json['isAuthenticated'] ?? false,
        resetToken: json['refreshToken'],
      );
}
