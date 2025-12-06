import 'package:json_annotation/json_annotation.dart';

part 'book_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
class Book {
  final String id;
  @JsonKey(name: 'isbn')
  final String? isbn;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'subtitle')
  final String? subtitle;
  @JsonKey(name: 'author')
  final String author;
  @JsonKey(name: 'translator')
  final String? translator;
  @JsonKey(name: 'publisher')
  final String? publisher;
  @JsonKey(name: 'publication_year')
  final int? publicationYear;
  @JsonKey(name: 'category')
  final String? category;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'quantity')
  final int quantity;
  @JsonKey(name: 'available_quantity')
  final int availableQuantity;
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // 保留旧字段以兼容（已废弃）
  @Deprecated('Use category instead')
  String? get categoryId => category;
  
  @Deprecated('Use coverImageUrl instead')
  String? get coverImage => coverImageUrl;
  
  @Deprecated('Use quantity instead')
  int get totalCopies => quantity;
  
  @Deprecated('Use availableQuantity instead')
  int get availableCopies => availableQuantity;

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

  factory Book.fromJson(Map<String, dynamic> json) {
    // 安全地解析数字字段
    int safeInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return defaultValue;
    }

    int? safeIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return null;
    }

    String safeString(dynamic value, String defaultValue) {
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

  Map<String, dynamic> toJson() => _$BookToJson(this);

  Book copyWith({
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
