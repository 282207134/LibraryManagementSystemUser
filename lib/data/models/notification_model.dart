import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Notification { // 通知模型
  final String id; // 通知ID
  final String userId; // 用户ID
  final String title; // 标题
  final String message; // 消息内容
  final String type; // 类型
  final bool isRead; // 是否已读
  final String? data; // 附加数据
  final String createdAt; // 创建时间

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification( // 从JSON创建Notification对象
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        type: json['type'] as String? ?? '',
        isRead: json['is_read'] as bool? ?? false,
        data: json['data'] as String?,
        createdAt: json['created_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => { // 转换为JSON
        'id': id,
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': isRead,
        'data': data,
        'created_at': createdAt,
      };

  Notification copyWith({ // 创建副本并修改指定字段
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? data,
    String? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
