import 'package:dio/dio.dart';
import 'package:library_management/data/models/api_response.dart';
import 'package:library_management/data/models/book_model.dart';
import 'package:library_management/data/models/borrow_record_model.dart';
import 'package:library_management/data/models/category_model.dart';
import 'package:library_management/data/models/notification_model.dart' as notif;
import 'package:library_management/data/models/user_model.dart';
import 'package:library_management/data/network/http_client.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = HttpClient().dio;
  }

  // Auth endpoints
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String username,
    required String password,
    required String email,
    required String studentId,
    String? phone,
    String? department,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'username': username,
          'password': password,
          'email': email,
          'studentId': studentId,
          'phone': phone,
          'department': department,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Registration failed',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Login failed',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dio.post('/api/auth/logout');
      return ApiResponse.fromJson(
        response.data,
        (json) => null,
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Logout failed',
        originalError: e,
      );
    }
  }

  // User endpoints
  Future<ApiResponse<User>> getUserProfile() async {
    try {
      final response = await _dio.get('/api/user/profile');
      return ApiResponse.fromJson(
        response.data,
        (json) => User.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to fetch user profile',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<User>> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put('/api/user/profile', data: data);
      return ApiResponse.fromJson(
        response.data,
        (json) => User.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to update user profile',
        originalError: e,
      );
    }
  }

  // Book endpoints
  Future<ApiResponse<List<Book>>> getBooks({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/books',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null) 'search': search,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => Book.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to fetch books',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<Book>> getBookDetail(String bookId) async {
    try {
      final response = await _dio.get('/api/books/$bookId');
      return ApiResponse.fromJson(
        response.data,
        (json) => Book.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to fetch book details',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<List<Book>>> searchBooks({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.post(
        '/api/books/search',
        data: {
          'query': query,
          'page': page,
          'pageSize': pageSize,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => Book.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Search failed',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      final response = await _dio.get('/api/categories');
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to fetch categories',
        originalError: e,
      );
    }
  }

  // Borrow endpoints
  Future<ApiResponse<BorrowRecord>> borrowBook(String bookId) async {
    try {
      final response = await _dio.post(
        '/api/borrow',
        data: {'bookId': bookId},
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => BorrowRecord.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to borrow book',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<BorrowRecord>> returnBook(String borrowRecordId) async {
    try {
      final response = await _dio.post(
        '/api/return',
        data: {'borrowRecordId': borrowRecordId},
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => BorrowRecord.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to return book',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<List<BorrowRecord>>> getBorrowHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/borrow/history',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => BorrowRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to fetch borrow history',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<List<BorrowRecord>>> getCurrentBorrows() async {
    try {
      final response = await _dio.get('/api/borrow/current');
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => BorrowRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to fetch current borrows',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<BorrowRecord>> renewBorrow(String borrowRecordId) async {
    try {
      final response = await _dio.post(
        '/api/borrow/renew',
        data: {'borrowRecordId': borrowRecordId},
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => BorrowRecord.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to renew borrow',
        originalError: e,
      );
    }
  }

  // Notification endpoints
  Future<ApiResponse<List<notif.Notification>>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/notifications',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => notif.Notification.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to fetch notifications',
        originalError: e,
      );
    }
  }

  Future<ApiResponse<notif.Notification>> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      final response = await _dio.put(
        '/api/notifications/$notificationId',
        data: {'isRead': true},
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => notif.Notification.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode,
        message: e.message ?? 'Failed to mark notification as read',
        originalError: e,
      );
    }
  }
}
