import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/core/network/api_client.dart';

part 'translation_state.dart';

class TranslationCubit extends Cubit<TranslationState> {
  final Dio _dio = ApiClient.getInstance();

  TranslationCubit() : super(TranslationInitial());

  Future<void> translateVideo(String videoPath) async {
    emit(TranslationLoading());
    await _sendVideo(videoPath, isRetryAfterRefresh: false);
  }

  Future<void> _sendVideo(
    String videoPath, {
    required bool isRetryAfterRefresh,
  }) async {
    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(
          videoPath,
          filename: 'sign_video.mp4',
        ),
      });

      final response = await _dio.post(
        '/api/Translation/process',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          extra: {'isMultipart': true, 'isRetry': isRetryAfterRefresh},
        ),
      );

      _handleSuccess(response.data);
    } on DioException catch (e) {
      if (e.error == 'TOKEN_REFRESHED_RETRY_NEEDED' && !isRetryAfterRefresh) {
        await _sendVideo(videoPath, isRetryAfterRefresh: true);
        return;
      }

      if (e.response?.statusCode == 401) {
        emit(TranslationError('auth_error'));
        return;
      }

      _handleDioError(e);
    } catch (e) {
      emit(TranslationError('unknown_error'));
    }
  }

  void _handleSuccess(dynamic responseData) {
    String prediction = '';

    if (responseData is String) {
      prediction = responseData.trim().replaceAll('"', '');
    } else if (responseData is Map) {
      prediction =
          responseData['data']?['prediction'] ??
          responseData['prediction'] ??
          responseData['message'] ??
          '';
    } else {
      prediction = responseData.toString().trim();
    }

    if (prediction.isEmpty) {
      emit(TranslationError('no_result'));
    } else {
      emit(TranslationSuccess(prediction));
    }
  }

  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 500) {
      emit(TranslationError('model_error'));
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      emit(TranslationError('timeout_error'));
    } else if (e.type == DioExceptionType.connectionError) {
      emit(TranslationError('network_error'));
    } else {
      emit(TranslationError('unknown_error'));
    }
  }

  void reset() => emit(TranslationInitial());
}
