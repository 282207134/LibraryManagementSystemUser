import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

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

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

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
