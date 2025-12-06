import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/data/models/review_model.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  SupabaseClient get _supabase => AppConfig.supabase;

  // 获取图书的所有评论
  Future<List<Review>> getReviews(String bookId) async {
    final response = await _supabase
        .from('reviews')
        .select('*')
        .eq('book_id', bookId)
        .order('created_at', ascending: false);

    if (response.isEmpty) {
      return [];
    }

    final reviews = (response as List)
        .map((json) => Review.fromJson(json as Map<String, dynamic>))
        .toList();

    // 获取用户信息
    if (reviews.isNotEmpty) {
      final userIds = reviews.map((r) => r.userId).toSet().toList();
      final usersResponse = await _supabase
          .from('users')
          .select('id, email, full_name')
          .inFilter('id', userIds);

      final usersMap = <String, Map<String, dynamic>>{};
      for (final user in usersResponse as List) {
        usersMap[user['id'] as String] = user as Map<String, dynamic>;
      }

      // 创建带用户信息的评论列表
      return reviews.map((review) {
        final user = usersMap[review.userId];
        if (user != null) {
          review.userEmail = user['email'] as String?;
          review.userFullName = user['full_name'] as String?;
        }
        return review;
      }).toList();
    }

    return reviews;
  }

  // 获取用户的评论
  Future<Review?> getUserReview(String bookId, String userId) async {
    final response = await _supabase
        .from('reviews')
        .select('*')
        .eq('book_id', bookId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Review.fromJson(response as Map<String, dynamic>);
  }

  // 提交评论（创建或更新）
  Future<Review?> submitReview(
    String bookId,
    String userId,
    int rating,
    String? comment,
  ) async {
    // 检查是否已存在评论
    final existingReview = await getUserReview(bookId, userId);

    if (existingReview != null) {
      // 更新现有评论
      final response = await _supabase
          .from('reviews')
          .update({
            'rating': rating,
            'comment': comment,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existingReview.id)
          .select()
          .single();

      return Review.fromJson(response as Map<String, dynamic>);
    } else {
      // 创建新评论
      final response = await _supabase
          .from('reviews')
          .insert({
            'book_id': bookId,
            'user_id': userId,
            'rating': rating,
            'comment': comment,
          })
          .select()
          .single();

      return Review.fromJson(response as Map<String, dynamic>);
    }
  }

  // 删除评论
  Future<bool> deleteReview(String reviewId, String userId) async {
    try {
      await _supabase
          .from('reviews')
          .delete()
          .eq('id', reviewId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('删除评论失败: $e');
      return false;
    }
  }

  // 获取图书的评分统计
  Future<BookRatingStats> getBookRatingStats(String bookId) async {
    final response = await _supabase
        .from('reviews')
        .select('rating')
        .eq('book_id', bookId);

    if (response.isEmpty) {
      return BookRatingStats(
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: [],
      );
    }

    final ratings = (response as List)
          .map((item) {
          final ratingValue = item['rating'];
          if (ratingValue == null) {
            return 0; // 或者选择其他合适的默认值
          }
          return ratingValue is int ? ratingValue : int.parse(ratingValue.toString());
        })
        .toList();

    final total = ratings.length;
    final sum = ratings.reduce((a, b) => a + b);
    final average = sum / total;

    // 计算评分分布
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final rating in ratings) {
      distribution[rating] = (distribution[rating] ?? 0) + 1;
    }

    return BookRatingStats(
      averageRating: (average * 10).round() / 10,
      totalReviews: total,
      ratingDistribution: [1, 2, 3, 4, 5]
          .map((rating) => RatingDistribution(
                rating: rating,
                count: distribution[rating] ?? 0,
              ))
          .toList(),
    );
  }
}

