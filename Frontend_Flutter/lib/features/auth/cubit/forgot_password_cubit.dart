import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ishara/features/auth/data/models/forgot_password_request.dart';
import 'package:ishara/features/auth/data/repositories/auth_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _repository = AuthRepository();

  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  Future<void> forgotPassword(String email) async {
    if (email.isEmpty) {
      emit(ForgotPasswordFailure('Please enter your email'));
      return;
    }

    emit(ForgotPasswordLoading());

    try {
      await _repository.forgotPassword(ForgotPasswordRequest(email: email));
      emit(ForgotPasswordSuccess(email));
    } on DioException catch (e) {
      emit(
        ForgotPasswordFailure(
          e.response?.data?['message'] ?? 'Something went wrong',
        ),
      );
    } catch (e) {
      emit(ForgotPasswordFailure('An unexpected error occurred'));
    }
  }
}
