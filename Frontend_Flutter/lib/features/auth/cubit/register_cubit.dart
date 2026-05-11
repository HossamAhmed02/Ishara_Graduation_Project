import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ishara/features/auth/data/models/register_request.dart';
import 'package:ishara/features/auth/data/repositories/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _repository = AuthRepository();

  RegisterCubit() : super(RegisterInitial());

  Future<void> register(RegisterRequest request) async {
    if (request.firstName.isEmpty ||
        request.lastName.isEmpty ||
        request.email.isEmpty ||
        request.password.isEmpty) {
      emit(RegisterFailure('Please fill all fields'));
      return;
    }

    final password = request.password;
    if (password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      emit(
        RegisterFailure(
          'Password must have 8+ characters, '
          'one uppercase, one number & one special character',
        ),
      );
      return;
    }

    emit(RegisterLoading());

    try {
      final response = await _repository.register(request);

      if (response.message?.toLowerCase().contains('success') == true ||
          response.message?.toLowerCase().contains('registered') == true) {
        emit(RegisterSuccess());
      } else {
        emit(RegisterFailure(response.message ?? 'Registration failed'));
      }
      // تعديل
    } on DioException catch (e) {
      String message = 'Registration failed';

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          message =
              data['message']?.toString() ??
              data['Message']?.toString() ??
              data['error']?.toString() ??
              'Registration failed';
        } else if (data is String) {
          message = data;
        }
      }

      emit(RegisterFailure(message));
    }
    // تعديل
  }
}
