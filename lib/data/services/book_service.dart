import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/data/models/book_model.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  SupabaseClient get _supabase => AppConfig.supabase;

  // 获取图书列表（支持分页和搜索）
  Future<List<Book>> getBooks({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? category,
  }) async {
    int from = (page - 1) * pageSize;
    int to = from + pageSize - 1;

    var query = _supabase.from('books').select('*');

    // 搜索功能
    if (search != null && search.isNotEmpty) {
      query = query.or('title.ilike.%$search%,author.ilike.%$search%');
    }

    // 分类筛选
    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    // 排序和分页
    final response = await query
        .order('created_at', ascending: false)
        .range(from, to);

    return (response as List)
        .map((json) => Book.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 获取图书详情
  Future<Book?> getBookById(String bookId) async {
    final response = await _supabase
        .from('books')
        .select('*')
        .eq('id', bookId)
        .maybeSingle();

    if (response == null) return null;
    return Book.fromJson(response as Map<String, dynamic>);
  }

  // 搜索图书
  Future<List<Book>> searchBooks(String query) async {
    final response = await _supabase
        .from('books')
        .select('*')
        .or('title.ilike.%$query%,author.ilike.%$query%')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Book.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 获取分类列表
  Future<List<String>> getCategories() async {
    final response = await _supabase
        .from('books')
        .select('category')
        .not('category', 'is', null);

    final categories = (response as List)
        .map((item) => item['category'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    return categories;
  }
}

