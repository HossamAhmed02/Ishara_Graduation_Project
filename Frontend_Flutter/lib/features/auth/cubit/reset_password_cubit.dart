import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ishara/features/auth/data/models/reset_password_request.dart';
import 'package:ishara/features/auth/data/repositories/auth_repository.dart';
import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository _repository = AuthRepository();

  ResetPasswordCubit() : super(ResetPasswordInitial());

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
    required String resetToken,
  }) async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      emit(ResetPasswordFailure('Please fill all fields'));
      return;
    }

    if (newPassword != confirmPassword) {
      emit(ResetPasswordFailure('Passwords do not match'));
      return;
    }

    if (newPassword.length < 8 ||
        !newPassword.contains(RegExp(r'[A-Z]')) ||
        !newPassword.contains(RegExp(r'[0-9]')) ||
        !newPassword.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      emit(
        ResetPasswordFailure(
          'Password must have 8+ characters, '
          'uppercase, number & special character',
        ),
      );
      return;
    }

    emit(ResetPasswordLoading());

    try {
      final response = await _repository.resetPassword(
        ResetPasswordRequest(
          email: email,
          newPassword: newPassword,
          token: resetToken,
        ),
      );

      if (response.isAuthenticated ||
          response.message?.toLowerCase().contains('success') == true) {
        emit(ResetPasswordSuccess());
      } else {
        emit(ResetPasswordFailure(response.message ?? 'Password reset failed'));
      }
    } on DioException catch (e) {
      emit(
        ResetPasswordFailure(
          e.response?.data?['message'] ?? 'Password reset failed',
        ),
      );
    } catch (e) {
      emit(ResetPasswordFailure('An unexpected error occurred'));
    }
  }
}
