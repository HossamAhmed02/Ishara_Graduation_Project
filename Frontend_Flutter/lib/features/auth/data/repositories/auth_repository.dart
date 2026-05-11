import 'package:dio/dio.dart';
import 'package:ishara/core/constants/api_constants.dart';
import 'package:ishara/core/network/api_client.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/verify_otp_request.dart';
import '../models/verify_otp_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/forgot_password_request.dart';
import '../models/forgot_password_response.dart';
import '../models/verify_reset_otp_request.dart';
import '../models/verify_reset_otp_response.dart';
import '../models/reset_password_request.dart';
import '../models/reset_password_response.dart';

class AuthRepository {
  final Dio _dio = ApiClient.getInstance();
  // تعديل
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  // تعديل
  Future<VerifyOtpResponse> verifyRegisterOtp(VerifyOtpRequest request) async {
    final response = await _dio.post(
      ApiConstants.verifyRegisterOtp,
      data: request.toJson(),
    );
    return VerifyOtpResponse.fromJson(response.data);
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data);
  }

  Future<ForgotPasswordResponse> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: request.toJson(),
    );
    return ForgotPasswordResponse.fromJson(response.data);
  }

  Future<VerifyResetOtpResponse> verifyResetPasswordOtp(
    VerifyResetOtpRequest request,
  ) async {
    final response = await _dio.post(
      ApiConstants.verifyResetPasswordOtp,
      data: request.toJson(),
    );
    return VerifyResetOtpResponse.fromJson(response.data);
  }

  Future<ResetPasswordResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    final response = await _dio.post(
      ApiConstants.resetPassword,
      data: request.toJson(),
    );
    return ResetPasswordResponse.fromJson(response.data);
  }
}
