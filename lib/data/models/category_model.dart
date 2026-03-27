import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final int? bookCount;
  final String createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.bookCount,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        icon: json['icon'] as String?,
        bookCount: json['book_count'] as int?,
        createdAt: json['created_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'book_count': bookCount,
        'created_at': createdAt,
      };

  Category copyWith({
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
