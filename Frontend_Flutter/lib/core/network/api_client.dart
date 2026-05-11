import 'package:dio/dio.dart';
import 'package:ishara/core/constants/api_constants.dart';
import 'package:ishara/core/services/token_service.dart';

class ApiClient {
  static Dio getInstance() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            if (error.requestOptions.extra['isRetry'] == true) {
              await TokenService.clearTokens();
              return handler.next(error);
            }

            try {
              final refreshed = await _refreshToken();

              if (refreshed) {
                if (error.requestOptions.extra['isMultipart'] != true) {
                  final newToken = await TokenService.getToken();
                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newToken';
                  options.extra['isRetry'] = true;
                  final retryResponse = await dio.fetch(options);
                  return handler.resolve(retryResponse);
                } else {
                  return handler.reject(
                    DioException(
                      requestOptions: error.requestOptions,
                      type: DioExceptionType.unknown,
                      error: 'TOKEN_REFRESHED_RETRY_NEEDED',
                    ),
                  );
                }
              } else {
                await TokenService.clearTokens();
                return handler.next(error);
              }
            } catch (e) {
              await TokenService.clearTokens();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  static Future<bool> _refreshToken() async {
    try {
      final oldToken = await TokenService.getToken();
      final oldRefreshToken = await TokenService.getRefreshToken();

      if (oldRefreshToken == null || oldRefreshToken.isEmpty) {
        return false;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'token': oldToken ?? '', 'refreshToken': oldRefreshToken},
      );

      final newToken = response.data['token'];
      final newRefreshToken = response.data['refreshToken'];

      if (newToken == null || newToken.isEmpty) return false;

      await TokenService.saveTokens(
        token: newToken,
        refreshToken: newRefreshToken,
        email: await TokenService.getEmail() ?? '',
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
