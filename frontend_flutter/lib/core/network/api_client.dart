import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static void init() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.getString(AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        String customMsg = 'An unexpected error occurred';
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          customMsg = 'Connection timed out. Please check your internet.';
        } else if (e.response != null) {
          final data = e.response?.data;
          if (data is Map && data['message'] != null) {
            customMsg = data['message'];
          } else {
            customMsg = 'Server error: ${e.response?.statusCode}';
          }
        } else {
          customMsg = 'Network error. Please try again.';
        }
        
        // Mutate the error message so repositories get a clean string
        final customError = DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: customMsg,
          message: customMsg,
        );
        return handler.next(customError);
      },
    ));
  }

  static Dio get instance => _dio;
}
