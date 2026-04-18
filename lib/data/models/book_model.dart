import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false) // JSON序列化配置
class Book { // 图书模型
  final String id; // 图书ID
  @JsonKey(name: 'isbn')
  final String? isbn; // ISBN号
  @JsonKey(name: 'title')
  final String title; // 书名
  @JsonKey(name: 'subtitle')
  final String? subtitle; // 副标题
  @JsonKey(name: 'author')
  final String author; // 作者
  @JsonKey(name: 'translator')
  final String? translator; // 译者
  @JsonKey(name: 'publisher')
  final String? publisher; // 出版社
  @JsonKey(name: 'publication_year')
  final int? publicationYear; // 出版年份
  @JsonKey(name: 'category')
  final String? category; // 分类
  @JsonKey(name: 'description')
  final String? description; // 描述
  @JsonKey(name: 'quantity')
  final int quantity; // 总数量
  @JsonKey(name: 'available_quantity')
  final int availableQuantity; // 可借数量
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl; // 封面图片URL
  @JsonKey(name: 'created_at')
  final String createdAt; // 创建时间
  @JsonKey(name: 'updated_at')
  final String? updatedAt; // 更新时间
  
  // 保留旧字段以兼容(已废弃)
  @Deprecated('Use category instead')
  String? get categoryId => category; // 获取分类ID(已废弃)
  
  @Deprecated('Use coverImageUrl instead')
  String? get coverImage => coverImageUrl; // 获取封面图片(已废弃)
  
  @Deprecated('Use quantity instead')
  int get totalCopies => quantity; // 获取总副本数(已废弃)
  
  @Deprecated('Use availableQuantity instead')
  int get availableCopies => availableQuantity; // 获取可用副本数(已废弃)

  Book({
    required this.id,
    this.isbn,
    this.title = '',
    this.subtitle,
    this.author = '',
    this.translator,
    this.publisher,
    this.publicationYear,
    this.category,
    this.description,
    this.quantity = 0,
    this.availableQuantity = 0,
    this.coverImageUrl,
    this.createdAt = '',
    this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) { // 从JSON创建Book对象
    // 安全地解析数字字段
    int safeInt(dynamic value, int defaultValue) { // 安全解析int
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return defaultValue;
    }

    int? safeIntNullable(dynamic value) { // 安全解析可空int
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return null;
    }

    String safeString(dynamic value, String defaultValue) { // 安全解析字符串
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }

    return Book(
      id: json['id'] as String? ?? '',
      isbn: json['isbn'] as String?,
      title: safeString(json['title'], ''),
      subtitle: json['subtitle'] as String?,
      author: safeString(json['author'], ''),
      translator: json['translator'] as String?,
      publisher: json['publisher'] as String?,
      publicationYear: safeIntNullable(json['publication_year']),
      category: json['category'] as String?,
      description: json['description'] as String?,
      quantity: safeInt(json['quantity'], 0),
      availableQuantity: safeInt(json['available_quantity'], 0),
      coverImageUrl: json['cover_image_url'] as String?,
      createdAt: safeString(json['created_at'], ''),
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => { // 转换为JSON
        'id': id,
        'isbn': isbn,
        'title': title,
        'subtitle': subtitle,
        'author': author,
        'translator': translator,
        'publisher': publisher,
        'publication_year': publicationYear,
        'category': category,
        'description': description,
        'quantity': quantity,
        'available_quantity': availableQuantity,
        'cover_image_url': coverImageUrl,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  Book copyWith({ // 创建副本并修改指定字段
    String? id,
    String? isbn,
    String? title,
    String? subtitle,
    String? author,
    String? translator,
    String? publisher,
    int? publicationYear,
    String? category,
    String? description,
    int? quantity,
    int? availableQuantity,
    String? coverImageUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      author: author ?? this.author,
      translator: translator ?? this.translator,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
      category: category ?? this.category,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
