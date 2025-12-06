import 'package:json_annotation/json_annotation.dart';
import 'package:library_management/data/models/book_model.dart';

part 'borrow_record_model.g.dart';

@JsonSerializable()
class BorrowRecord {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'book_id')
  final String bookId;
  @JsonKey(name: 'borrowed_at')
  final String borrowedAt;
  @JsonKey(name: 'due_date')
  final String dueDate;
  @JsonKey(name: 'returned_at')
  final String? returnedAt;
  final String status;
  @JsonKey(name: 'renew_count')
  final int renewCount;
  final double? fine;
  
  // 嵌套的book对象（从join查询获取）
  @JsonKey(name: 'books')
  final Book? book;

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

  factory BorrowRecord.fromJson(Map<String, dynamic> json) {
    // 保守解析，防止后端返回 null 时的类型转换错误
    int safeInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return defaultValue;
    }

    double? safeDouble(dynamic value) {
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

  Map<String, dynamic> toJson() => _$BorrowRecordToJson(this);

  BorrowRecord copyWith({
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
  String get borrowDate => borrowedAt;
  
  @Deprecated('Use returnedAt instead')
  String? get returnDate => returnedAt;
}
