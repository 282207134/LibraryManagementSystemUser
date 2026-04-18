import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Category { // 分类模型
  final String id; // 分类ID
  final String name; // 分类名称
  final String? description; // 描述
  final String? icon; // 图标
  final int? bookCount; // 图书数量
  final String createdAt; // 创建时间

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.bookCount,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category( // 从JSON创建Category对象
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        icon: json['icon'] as String?,
        bookCount: json['book_count'] as int?,
        createdAt: json['created_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => { // 转换为JSON
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'book_count': bookCount,
        'created_at': createdAt,
      };

  Category copyWith({ // 创建副本并修改指定字段
    String? id,
    String? name,
    String? description,
    String? icon,
    int? bookCount,
    String? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      bookCount: bookCount ?? this.bookCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
