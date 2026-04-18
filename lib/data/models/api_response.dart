import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> { // API响应模型
  final int code; // 状态码
  final String message; // 消息
  final T? data; // 数据
  final int? timestamp; // 时间戳

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.timestamp,
  });

  bool get isSuccess => code == 200; // 判断是否成功

  factory ApiResponse.fromJson( // 从JSON创建ApiResponse对象
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      ApiResponse(
        code: json['code'] as int? ?? 0,
        message: json['message'] as String? ?? '',
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        timestamp: json['timestamp'] as int?,
      );

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => { // 转换为JSON
        'code': code,
        'message': message,
        'data': data != null ? toJsonT(data as T) : null,
        'timestamp': timestamp,
      };
}

class ApiException implements Exception { // API异常
  final int? code; // 错误码
  final String message; // 错误消息
  final dynamic originalError; // 原始错误

  ApiException({
    this.code,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (code: $code)'; // 转换为字符串
}
