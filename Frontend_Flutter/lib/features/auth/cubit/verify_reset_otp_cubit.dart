import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ishara/features/auth/data/models/verify_reset_otp_request.dart';
import 'package:ishara/features/auth/data/repositories/auth_repository.dart';
import 'verify_reset_otp_state.dart';

class VerifyResetOtpCubit extends Cubit<VerifyResetOtpState> {
  final AuthRepository _repository = AuthRepository();

  VerifyResetOtpCubit() : super(VerifyResetOtpInitial());

  Future<void> verifyOtp({required String email, required String otp}) async {
    if (otp.length < 6) {
      emit(VerifyResetOtpFailure('Please enter the complete OTP'));
      return;
    }

    emit(VerifyResetOtpLoading());

    try {
      final response = await _repository.verifyResetPasswordOtp(
        VerifyResetOtpRequest(email: email, otp: otp),
      );

      if (response.message?.toLowerCase().contains('valid') == true &&
          response.resetToken != null) {
        emit(
          VerifyResetOtpSuccess(email: email, resetToken: response.resetToken!),
        );
      } else {
        emit(
          VerifyResetOtpFailure(response.message ?? 'OTP verification failed'),
        );
      }
    } on DioException catch (e) {
      emit(
        VerifyResetOtpFailure(
          e.response?.data?['message'] ?? 'OTP verification failed',
        ),
      );
    } catch (e) {
      emit(VerifyResetOtpFailure('An unexpected error occurred'));
    }
  }
}
