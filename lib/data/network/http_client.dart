import 'package:dio/dio.dart';
import 'package:library_management/config/app_config.dart';

class HttpClient { // HTTP客户端单例
  static final HttpClient _instance = HttpClient._internal(); // 单例实例

  late Dio _dio; // Dio实例

  factory HttpClient() => _instance; // 工厂方法返回单例

  HttpClient._internal() { // 私有构造函数
    _initializeDio();
  }

  Dio get dio => _dio; // 获取Dio实例

  void _initializeDio() { // 初始化Dio配置
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl, // API基础URL
        connectTimeout: const Duration(milliseconds: AppConfig.connectionTimeout), // 连接超时
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout), // 接收超时
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'zh-CN',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(), // 认证拦截器
      _LoggingInterceptor(), // 日志拦截器
      _ErrorInterceptor(), // 错误拦截器
    ]);
  }

  Future<void> setToken(String token) async { // 设置认证令牌
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() { // 清除认证令牌
    _dio.options.headers.remove('Authorization');
  }
}

class _AuthInterceptor extends Interceptor { // 认证拦截器
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor { // 日志拦截器
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🔵 Request: ${options.method} ${options.path}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('🟢 Response: ${response.statusCode} ${response.requestOptions.path}');
    print('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🔴 Error: ${err.message}');
    print('Status Code: ${err.response?.statusCode}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor { // 错误拦截器
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) { // 处理401未授权错误
      print('Token expired, redirecting to login...');
      // Handle token expiration here
    }
    handler.next(err);
  }
}
