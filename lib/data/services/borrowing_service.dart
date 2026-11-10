import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/data/models/borrow_record_model.dart';
import 'package:library_management/data/models/borrow_request_model.dart';

enum BookBorrowingState { available, pending, borrowed }

class BorrowingService {
  BorrowingService({SupabaseClient? client}) : _client = client;
  final SupabaseClient? _client;
  SupabaseClient get _supabase => _client ?? AppConfig.supabase;
  String? get currentUserId => _supabase.auth.currentUser?.id;

  static const _bookFields = '*, books(id,title,author,cover_image_url)';

  // Requests use the authenticated reader, without reserving stock.
  Future<Map<String, dynamic>> requestBook({
    required String bookId,
    int days = 30,
  }) async =>
      Map<String, dynamic>.from(await _supabase.rpc(
        'request_borrow_book',
        params: {'p_book_id': bookId, 'p_days': days},
      ) as Map);

  Future<Map<String, dynamic>> cancelRequest(String requestId) async =>
      Map<String, dynamic>.from(await _supabase.rpc(
        'close_borrow_request',
        params: {
          'p_request_id': requestId,
          'p_action': 'cancelled',
          'p_note': null,
        },
      ) as Map);

  Future<List<BorrowRequest>> getUserRequests(String userId) async {
    final response = await _supabase
        .from('borrowing_requests')
        .select(_bookFields)
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map(BorrowRequest.fromJson).toList();
  }

  Future<List<BorrowRecord>> getUserBorrowings(String userId) async {
    final response = await _supabase
        .from('borrowing_records')
        .select(_bookFields)
        .eq('user_id', userId)
        .order('borrowed_at', ascending: false);
    return response.map(BorrowRecord.fromJson).toList();
  }

  Future<BookBorrowingState> getBookBorrowingState(
    String userId,
    String bookId,
  ) async {
    final results = await Future.wait([
      _supabase
          .from('borrowing_records')
          .select('id')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .inFilter('status', ['borrowed', 'overdue']).limit(1),
      _supabase
          .from('borrowing_requests')
          .select('id')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .eq('status', 'pending')
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .limit(1),
    ]);
    if (results[0].isNotEmpty) return BookBorrowingState.borrowed;
    if (results[1].isNotEmpty) return BookBorrowingState.pending;
    return BookBorrowingState.available;
  }
}
