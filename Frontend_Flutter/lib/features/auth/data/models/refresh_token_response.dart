class RefreshTokenResponse {
  final String token;
  final String refreshToken;

  RefreshTokenResponse({required this.token, required this.refreshToken});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      RefreshTokenResponse(
        token: json['token'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
      );
}
