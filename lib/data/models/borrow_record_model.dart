import 'package:json_annotation/json_annotation.dart';
import 'package:library_management/data/models/book_model.dart';

@JsonSerializable()
class BorrowRecord { // 借阅记录模型
  final String id; // 记录ID
  @JsonKey(name: 'user_id')
  final String userId; // 用户ID
  @JsonKey(name: 'book_id')
  final String bookId; // 图书ID
  @JsonKey(name: 'borrowed_at')
  final String borrowedAt; // 借阅时间
  @JsonKey(name: 'due_date')
  final String dueDate; // 应还日期
  @JsonKey(name: 'returned_at')
  final String? returnedAt; // 归还时间
  final String status; // 状态
  @JsonKey(name: 'renew_count')
  final int renewCount; // 续借次数
  final double? fine; // 罚款金额
  
  // 嵌套的book对象(从join查询获取)
  @JsonKey(name: 'books')
  final Book? book; // 关联的图书信息

  BorrowRecord({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.borrowedAt,
    required this.dueDate,
    this.returnedAt,
    required this.status,
    required this.renewCount,
    this.fine,
    this.book,
  });

  factory BorrowRecord.fromJson(Map<String, dynamic> json) { // 从JSON创建BorrowRecord对象
    // 保守解析,防止后端返回 null 时的类型转换错误
    int safeInt(dynamic value, {int defaultValue = 0}) { // 安全解析int
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return defaultValue;
    }

    double? safeDouble(dynamic value) { // 安全解析double
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return BorrowRecord(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      bookId: json['book_id'] as String? ?? '',
      borrowedAt: json['borrowed_at'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      returnedAt: json['returned_at'] as String?,
      status: json['status'] as String? ?? '',
      renewCount: safeInt(json['renew_count']),
      fine: safeDouble(json['fine']),
      book: json['books'] == null
          ? null
          : Book.fromJson(json['books'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => { // 转换为JSON
        'id': id,
        'user_id': userId,
        'book_id': bookId,
        'borrowed_at': borrowedAt,
        'due_date': dueDate,
        'returned_at': returnedAt,
        'status': status,
        'renew_count': renewCount,
        'fine': fine,
        'books': book?.toJson(),
      };

  BorrowRecord copyWith({ // 创建副本并修改指定字段
    String? id,
    String? userId,
    String? bookId,
    String? borrowedAt,
    String? dueDate,
    String? returnedAt,
    String? status,
    int? renewCount,
    double? fine,
    Book? book,
  }) {
    return BorrowRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      borrowedAt: borrowedAt ?? this.borrowedAt,
      dueDate: dueDate ?? this.dueDate,
      returnedAt: returnedAt ?? this.returnedAt,
      status: status ?? this.status,
      renewCount: renewCount ?? this.renewCount,
      fine: fine ?? this.fine,
      book: book ?? this.book,
    );
  }
  
  // 兼容旧字段名
  @Deprecated('Use borrowedAt instead')
  String get borrowDate => borrowedAt; // 获取借阅日期(已废弃)
  
  @Deprecated('Use returnedAt instead')
  String? get returnDate => returnedAt; // 获取归还日期(已废弃)
}
