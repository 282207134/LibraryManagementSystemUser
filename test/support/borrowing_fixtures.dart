import 'package:library_management/data/models/book_model.dart';
import 'package:library_management/data/models/borrow_record_model.dart';
import 'package:library_management/data/models/borrow_request_model.dart';
import 'package:library_management/data/services/borrowing_service.dart';

BorrowRequest requestFixture(
        {String status = 'pending', String? loanId, DateTime? expiry}) =>
    BorrowRequest(
      id: 'request-test',
      bookId: 'book-test',
      pickupCode: '12345678',
      status: status,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      expiresAt: expiry ?? DateTime.now().add(const Duration(hours: 47)),
      borrowingId: loanId,
      reviewNote: status == 'rejected' ? '测试审核说明' : null,
      book: Book.fromJson(
          {'id': 'book-test', 'title': '扫码联测图书', 'author': 'Test Author'}),
    );

BorrowRecord loanFixture({String status = 'borrowed'}) => BorrowRecord(
      id: 'loan-test',
      userId: 'reader-test',
      bookId: 'book-test',
      borrowedAt: DateTime.now()
          .subtract(const Duration(days: 2))
          .toUtc()
          .toIso8601String(),
      dueDate: DateTime.now()
          .subtract(const Duration(hours: 1))
          .toUtc()
          .toIso8601String(),
      returnedAt: status == 'returned'
          ? DateTime.now().toUtc().toIso8601String()
          : null,
      status: status,
      renewCount: 0,
      book: Book.fromJson(
          {'id': 'book-test', 'title': '扫码联测图书', 'author': 'Test Author'}),
    );

class MemoryBorrowingService extends BorrowingService {
  @override
  String? get currentUserId => 'reader-test';
  List<BorrowRequest> requests = [requestFixture()];
  List<BorrowRecord> loans = [];
  bool failLoad = false;
  int cancelled = 0;
  @override
  Future<List<BorrowRequest>> getUserRequests(String userId) async {
    if (failLoad) throw StateError('test network failure');
    return requests;
  }

  @override
  Future<List<BorrowRecord>> getUserBorrowings(String userId) async => loans;
  @override
  Future<Map<String, dynamic>> cancelRequest(String requestId) async {
    cancelled++;
    requests = [requestFixture(status: 'cancelled')];
    return {'success': true};
  }
}
