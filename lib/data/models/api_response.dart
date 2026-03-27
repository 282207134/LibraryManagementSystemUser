import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final int? timestamp;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.timestamp,
  });

  bool get isSuccess => code == 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      ApiResponse(
        code: json['code'] as int? ?? 0,
        message: json['message'] as String? ?? '',
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        timestamp: json['timestamp'] as int?,
      );

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => {
        'code': code,
        'message': message,
        'data': data != null ? toJsonT(data as T) : null,
        'timestamp': timestamp,
      };
}

class ApiException implements Exception {
  final int? code;
  final String message;
  final dynamic originalError;

  ApiException({
    this.code,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (code: $code)';
}
