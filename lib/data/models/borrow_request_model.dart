import 'package:library_management/data/models/book_model.dart';

class BorrowRequest {
  const BorrowRequest({
    required this.id,
    required this.bookId,
    required this.pickupCode,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.borrowingId,
    this.reviewNote,
    this.book,
  });

  final String id, bookId, pickupCode, status;
  final DateTime createdAt, expiresAt;
  final String? borrowingId, reviewNote;
  final Book? book;

  String statusAt(DateTime now) =>
      status == 'pending' && !expiresAt.isAfter(now) ? 'expired' : status;

  factory BorrowRequest.fromJson(Map<String, dynamic> json) => BorrowRequest(
        id: json['id'] as String,
        bookId: json['book_id'] as String,
        pickupCode: json['pickup_code'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        expiresAt: DateTime.parse(json['expires_at'] as String),
        borrowingId: json['borrowing_id'] as String?,
        reviewNote: json['review_note'] as String?,
        book: json['books'] == null
            ? null
            : Book.fromJson(json['books'] as Map<String, dynamic>),
      );
}
