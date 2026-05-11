import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ishara/core/services/token_service.dart';
import 'package:ishara/features/auth/data/models/login_request.dart';
import 'package:ishara/features/auth/data/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _repository = AuthRepository();

  LoginCubit() : super(LoginInitial());

  Future<void> login(LoginRequest request) async {
    if (request.email.isEmpty || request.password.isEmpty) {
      emit(LoginFailure('Please fill all fields'));
      return;
    }

    emit(LoginLoading());

    try {
      final response = await _repository.login(request);

      if (response.isAuthenticated && response.token.isNotEmpty) {
        await TokenService.saveTokens(
          token: response.token,
          refreshToken: response.refreshToken,
          email: response.email,
        );
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(response.message ?? 'Login failed'));
      }
    } on DioException catch (e) {
      emit(LoginFailure(e.response?.data?['message'] ?? 'Login failed'));
    } catch (e) {
      emit(LoginFailure('An unexpected error occurred'));
    }
  }
}
