class VerifyResetOtpRequest {
  final String email;
  final String otp;

  VerifyResetOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}
