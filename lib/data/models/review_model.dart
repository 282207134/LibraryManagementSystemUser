import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

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

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
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

  factory BookRatingStats.fromJson(Map<String, dynamic> json) =>
      _$BookRatingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$BookRatingStatsToJson(this);
}

@JsonSerializable()
class RatingDistribution {
  final int rating;
  final int count;

  RatingDistribution({
    required this.rating,
    required this.count,
  });

  factory RatingDistribution.fromJson(Map<String, dynamic> json) =>
      _$RatingDistributionFromJson(json);

  Map<String, dynamic> toJson() => _$RatingDistributionToJson(this);
}

