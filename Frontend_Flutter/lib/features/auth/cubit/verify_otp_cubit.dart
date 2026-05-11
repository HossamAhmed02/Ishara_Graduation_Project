import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ishara/features/auth/data/models/verify_otp_request.dart';
import 'package:ishara/features/auth/data/repositories/auth_repository.dart';
import 'verify_otp_state.dart';

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthRepository _repository = AuthRepository();

  VerifyOtpCubit() : super(VerifyOtpInitial());

  Future<void> verifyOtp({required String email, required String otp}) async {
    if (otp.length < 6) {
      emit(VerifyOtpFailure('Please enter the complete OTP'));
      return;
    }

    emit(VerifyOtpLoading());

    try {
      final response = await _repository.verifyRegisterOtp(
        VerifyOtpRequest(email: email, otp: otp),
      );

      if (response.isAuthenticated) {
        emit(VerifyOtpSuccess());
      } else {
        emit(VerifyOtpFailure(response.message ?? 'OTP verification failed'));
      }
    } on DioException catch (e) {
      emit(
        VerifyOtpFailure(
          e.response?.data?['message'] ?? 'OTP verification failed',
        ),
      );
    } catch (e) {
      emit(VerifyOtpFailure('An unexpected error occurred'));
    }
  }
}
