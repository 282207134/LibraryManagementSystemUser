import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/data/models/borrow_record_model.dart';

class BorrowingService {
  static final BorrowingService _instance = BorrowingService._internal();
  factory BorrowingService() => _instance;
  BorrowingService._internal();

  SupabaseClient get _supabase => AppConfig.supabase;

  // 借阅图书（使用数据库函数）
  Future<Map<String, dynamic>> borrowBook({
    required String bookId,
    required String userId,
    int days = 30,
  }) async {
    final response = await _supabase.rpc('borrow_book', params: {
      'p_book_id': bookId,
      'p_user_id': userId,
      'p_days': days,
    });

    return response as Map<String, dynamic>;
  }

  // 归还图书（使用数据库函数）
  Future<Map<String, dynamic>> returnBook(String borrowingId) async {
    final response = await _supabase.rpc('return_book', params: {
      'p_borrowing_id': borrowingId,
    });

    return response as Map<String, dynamic>;
  }

  // 获取用户的借阅记录
  Future<List<BorrowRecord>> getUserBorrowings(String userId) async {
    final response = await _supabase
        .from('borrowing_records')
        .select('''
          *,
          books (
            id,
            title,
            author,
            cover_image_url
          )
        ''')
        .eq('user_id', userId)
        .order('borrowed_at', ascending: false);

    return (response as List)
        .map((json) => BorrowRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 获取当前借阅中的图书
  Future<List<BorrowRecord>> getCurrentBorrowings(String userId) async {
    final response = await _supabase
        .from('borrowing_records')
        .select('''
          *,
          books (
            id,
            title,
            author,
            cover_image_url
          )
        ''')
        .eq('user_id', userId)
        .inFilter('status', ['borrowed', 'overdue'])
        .order('borrowed_at', ascending: false);

    return (response as List)
        .map((json) => BorrowRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 续借
  Future<void> renewBorrow(String borrowingId) async {
    // 如果数据库有续借函数，使用它；否则更新 due_date
    await _supabase
        .from('borrowing_records')
        .update({
          'due_date': DateTime.now()
              .add(const Duration(days: 30))
              .toIso8601String(),
        })
        .eq('id', borrowingId);
  }
}

