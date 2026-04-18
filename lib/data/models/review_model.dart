import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Review { // 评论模型
  final String id; // 评论ID
  @JsonKey(name: 'book_id')
  final String bookId; // 图书ID
  @JsonKey(name: 'user_id')
  final String userId; // 用户ID
  final int rating; // 评分(1-5)
  final String? comment; // 评论内容
  @JsonKey(name: 'created_at')
  final String? createdAt; // 创建时间
  @JsonKey(name: 'updated_at')
  final String? updatedAt; // 更新时间
  
  // 从join查询获取的用户信息(不在JSON中,需要手动设置)
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? userEmail; // 用户邮箱
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? userFullName; // 用户全名

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

  factory Review.fromJson(Map<String, dynamic> json) => Review( // 从JSON创建Review对象 // 从JSON创建Review对象
        id: json['id'] as String? ?? '',
        bookId: json['book_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        rating: json['rating'] as int? ?? 0,
        comment: json['comment'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => { // 转换为JSON
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
class BookRatingStats { // 图书评分统计
  @JsonKey(name: 'average_rating')
  final double averageRating; // 平均评分
  @JsonKey(name: 'total_reviews')
  final int totalReviews; // 总评论数
  @JsonKey(name: 'rating_distribution')
  final List<RatingDistribution> ratingDistribution; // 评分分布

  BookRatingStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory BookRatingStats.fromJson(Map<String, dynamic> json) => BookRatingStats( // 从JSON创建BookRatingStats对象 // 从JSON创建BookRatingStats对象
        averageRating: json['average_rating'] as double? ?? 0.0,
        totalReviews: json['total_reviews'] as int? ?? 0,
        ratingDistribution: (json['rating_distribution'] as List?)
                ?.map((e) => RatingDistribution.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => { // 转换为JSON
        'average_rating': averageRating,
        'total_reviews': totalReviews,
        'rating_distribution': ratingDistribution.map((e) => e.toJson()).toList(),
      };
}

@JsonSerializable()
class RatingDistribution { // 评分分布
  final int rating; // 评分值
  final int count; // 数量

  RatingDistribution({
    required this.rating,
    required this.count,
  });

  factory RatingDistribution.fromJson(Map<String, dynamic> json) => RatingDistribution( // 从JSON创建RatingDistribution对象 // 从JSON创建RatingDistribution对象
        rating: json['rating'] as int? ?? 0,
        count: json['count'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => { // 转换为JSON
        'rating': rating,
        'count': count,
      };
}

