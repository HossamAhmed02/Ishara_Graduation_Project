class RegisterResponse {
  final String? message;
  final bool isAuthenticated;

  RegisterResponse({this.message, required this.isAuthenticated});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        message: json['message'],
        isAuthenticated: json['isAuthenticated'] ?? false,
      );
}
