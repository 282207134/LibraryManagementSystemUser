import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Review {
  final String id;
  @JsonKey(name: 'book_id')
  final String bookId;
  @JsonKey(name: 'user_id')
  final String userId;
  final int rating;
  final String? comment;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // 从join查询获取的用户信息（不在JSON中，需要手动设置）
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? userEmail;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? userFullName;

  Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.userEmail,
    this.userFullName,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String? ?? '',
        bookId: json['book_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        rating: json['rating'] as int? ?? 0,
        comment: json['comment'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'book_id': bookId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

@JsonSerializable()
class BookRatingStats {
  @JsonKey(name: 'average_rating')
  final double averageRating;
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @JsonKey(name: 'rating_distribution')
  final List<RatingDistribution> ratingDistribution;

  BookRatingStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory BookRatingStats.fromJson(Map<String, dynamic> json) => BookRatingStats(
        averageRating: json['average_rating'] as double? ?? 0.0,
        totalReviews: json['total_reviews'] as int? ?? 0,
        ratingDistribution: (json['rating_distribution'] as List?)
                ?.map((e) => RatingDistribution.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'average_rating': averageRating,
        'total_reviews': totalReviews,
        'rating_distribution': ratingDistribution.map((e) => e.toJson()).toList(),
      };
}

@JsonSerializable()
class RatingDistribution {
  final int rating;
  final int count;

  RatingDistribution({
    required this.rating,
    required this.count,
  });

  factory RatingDistribution.fromJson(Map<String, dynamic> json) => RatingDistribution(
        rating: json['rating'] as int? ?? 0,
        count: json['count'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'count': count,
      };
}

