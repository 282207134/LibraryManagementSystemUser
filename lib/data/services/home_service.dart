import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/data/models/book_model.dart';

class HomeService {
  static final HomeService _instance = HomeService._internal();
  factory HomeService() => _instance;
  HomeService._internal();

  SupabaseClient get _supabase => AppConfig.supabase;

  // 获取精选推荐图书（高评分图书，平均评分 >= 4.0）
  Future<List<Book>> getRecommendedBooks({int limit = 10}) async {
    try {
      // 先获取有评分的图书及其平均分
      final reviewsResponse = await _supabase
          .from('reviews')
          .select('book_id, rating');

      if (reviewsResponse.isEmpty) {
        // 如果没有评分，返回最近添加的图书
        final booksResponse = await _supabase
            .from('books')
            .select('*')
            .order('created_at', ascending: false)
            .limit(limit);
        return (booksResponse as List)
            .map((json) => Book.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // 计算每本书的平均评分
      final Map<String, List<int>> bookRatings = {};
      for (final review in reviewsResponse as List) {
        final bookId = review['book_id'] as String;
        final rating = review['rating'] as int;
        if (!bookRatings.containsKey(bookId)) {
          bookRatings[bookId] = [];
        }
        bookRatings[bookId]!.add(rating);
      }

      // 筛选平均分 >= 4.0 的图书
      final highRatedBookIds = <String>[];
      bookRatings.forEach((bookId, ratings) {
        final avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
        if (avgRating >= 4.0) {
          highRatedBookIds.add(bookId);
        }
      });

      if (highRatedBookIds.isEmpty) {
        // 如果没有高评分图书，返回所有有评分的图书
        highRatedBookIds.addAll(bookRatings.keys);
      }

      // 随机打乱并取前 limit 个
      highRatedBookIds.shuffle();
      final selectedIds = highRatedBookIds.take(limit).toList();

      if (selectedIds.isEmpty) {
        // 如果还是没有，返回最近添加的图书
        final booksResponse = await _supabase
            .from('books')
            .select('*')
            .order('created_at', ascending: false)
            .limit(limit);
        return (booksResponse as List)
            .map((json) => Book.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      final booksResponse = await _supabase
          .from('books')
          .select('*')
          .inFilter('id', selectedIds);

      return (booksResponse as List)
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('获取推荐图书失败: $e');
      return [];
    }
  }

  // 获取人气排行榜（按借阅次数排序）
  Future<List<Book>> getPopularBooks({int limit = 10}) async {
    try {
      // 统计每本书的借阅次数
      final borrowResponse = await _supabase
          .from('borrowing_records')
          .select('book_id');

      final Map<String, int> borrowCounts = {};
      for (final record in borrowResponse as List) {
        final bookId = record['book_id'] as String;
        borrowCounts[bookId] = (borrowCounts[bookId] ?? 0) + 1;
      }

      // 获取所有图书
      final allBooksResponse = await _supabase.from('books').select('*');
      final allBooks = (allBooksResponse as List)
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();

      // 添加借阅次数并排序
      for (final book in allBooks) {
        // 可以在这里添加借阅次数到book对象，但Book模型可能没有这个字段
        // 暂时只按借阅次数排序
      }

      allBooks.sort((a, b) {
        final countA = borrowCounts[a.id] ?? 0;
        final countB = borrowCounts[b.id] ?? 0;
        return countB.compareTo(countA);
      });

      return allBooks.take(limit).toList();
    } catch (e) {
      print('获取人气图书失败: $e');
      return [];
    }
  }

  // 获取新上架图书
  Future<List<Book>> getNewBooks({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('books')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('获取新上架图书失败: $e');
      return [];
    }
  }

  // 获取所有分类
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('books')
          .select('category')
          .not('category', 'is', null);

      final categories = <String>{};
      for (final item in response as List) {
        final category = item['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      print('获取分类失败: $e');
      return [];
    }
  }

  // 按分类获取图书
  Future<List<Book>> getBooksByCategory(String category, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('books')
          .select('*')
          .eq('category', category)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('获取分类图书失败: $e');
      return [];
    }
  }
}

