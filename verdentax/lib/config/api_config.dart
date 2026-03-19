import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';

class ApiConfig {
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  late Dio _dio;
  final Logger _logger = Logger();

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: Duration(seconds: AppConfig.connectionTimeout),
      receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
      sendTimeout: Duration(seconds: AppConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': '${AppConfig.appName}/${AppConfig.appVersion}',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: AppConfig.enableLogging,
      responseHeader: true,
      responseBody: AppConfig.enableLogging,
      error: true,
      logPrint: (object) {
        if (AppConfig.enableLogging) {
          _logger.d(object);
        }
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d('API Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('API Response: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('API Error: ${error.requestOptions.path} - ${error.message}');
        return handler.next(error);
      },
    ));
  }

  // Add authorization header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization header
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Check if network is available
  Future<bool> isNetworkAvailable() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get API status
  Future<Map<String, dynamic>> getApiStatus() async {
    try {
      final response = await _dio.get('/api/status');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get API status: $e');
    }
  }

  // Validate API response
  bool validateResponse(Response response) {
    if (response.statusCode != null) {
      return response.statusCode! >= 200 && response.statusCode! < 300;
    }
    return false;
  }

  // Handle API errors
  String handleApiError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return AppConfig.networkError;
        case DioExceptionType.sendTimeout:
          return AppConfig.networkError;
        case DioExceptionType.receiveTimeout:
          return AppConfig.networkError;
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return AppConfig.authError;
          } else if (error.response?.statusCode == 500) {
            return AppConfig.serverError;
          } else {
            return error.response?.data?['message'] ?? AppConfig.serverError;
          }
        case DioExceptionType.cancel:
          return 'Requête annulée';
        case DioExceptionType.connectionError:
          return AppConfig.networkError;
        case DioExceptionType.badCertificate:
          return 'Erreur de certificat SSL';
        case DioExceptionType.unknown:
          return AppConfig.networkError;
      }
    }
    return AppConfig.serverError;
  }
}
