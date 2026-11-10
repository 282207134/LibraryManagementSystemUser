import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_management/data/services/borrowing_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late HttpServer server;
  late SupabaseClient client;
  late BorrowingService service;
  final calls = <({Uri uri, String method, Map<String, dynamic> body})>[];
  var failRequests = false;
  var haveLoan = false;
  var haveRequest = false;
  setUp(() async {
    calls.clear();
    failRequests = false;
    haveLoan = false;
    haveRequest = false;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final raw = await utf8.decoder.bind(request).join();
      calls.add((
        uri: request.uri,
        method: request.method,
        body: raw.isEmpty ? {} : jsonDecode(raw) as Map<String, dynamic>
      ));
      request.response.headers.contentType = ContentType.json;
      Object result;
      final endpoint = request.uri.pathSegments.last;
      if (endpoint == 'request_borrow_book') {
        result = {
          'success': true,
          'status': 'pending',
          'request_id': 'test-request',
          'pickup_code': '12345678'
        };
      } else if (endpoint == 'close_borrow_request') {
        result = {'success': true};
      } else if (failRequests && endpoint == 'borrowing_requests') {
        request.response.statusCode = 503;
        result = {'message': 'Test network error', 'code': 'TEST'};
      } else if (request.uri.queryParameters['select'] == 'id') {
        final present =
            endpoint == 'borrowing_records' ? haveLoan : haveRequest;
        result = present
            ? [
                {'id': 'test-id'}
              ]
            : [];
      } else if (endpoint == 'borrowing_requests') {
        result = [
          {
            'id': 'test-request',
            'book_id': 'test-book',
            'pickup_code': '12345678',
            'status': 'pending',
            'created_at': '2026-11-10T00:00:00Z',
            'expires_at': '2026-11-12T00:00:00Z',
            'books': {
              'id': 'test-book',
              'title': 'Fixture Book',
              'author': 'Author'
            },
          }
        ];
      } else {
        result = [];
      }
      request.response.write(jsonEncode(result));
      await request.response.close();
    });
    client = SupabaseClient(
        'http://127.0.0.1:${server.port}', 'local-test-public-key');
    service = BorrowingService(client: client);
  });
  tearDown(() async {
    await client.dispose();
    await server.close(force: true);
  });

  test('Request RPC derives reader from session and returns a pending pass',
      () async {
    final result = await service.requestBook(bookId: 'test-book');
    expect(calls.single.uri.path, '/rest/v1/rpc/request_borrow_book');
    expect(calls.single.method, 'POST');
    expect(calls.single.body, {'p_book_id': 'test-book', 'p_days': 30});
    expect(result['status'], 'pending');
    expect(result['pickup_code'], '12345678');
  });

  test('Cancellation uses the checked request RPC, never a table write',
      () async {
    await service.cancelRequest('test-request');
    expect(calls.single.uri.path, '/rest/v1/rpc/close_borrow_request');
    expect(calls.single.body, {
      'p_request_id': 'test-request',
      'p_action': 'cancelled',
      'p_note': null
    });
  });

  test('Request reads are user-scoped and retain code, dates and joined book',
      () async {
    final rows = await service.getUserRequests('test-reader');
    expect(calls.single.uri.queryParameters['user_id'], 'eq.test-reader');
    expect(rows.single.pickupCode, '12345678');
    expect(rows.single.expiresAt, DateTime.utc(2026, 11, 12));
    expect(rows.single.book!.title, 'Fixture Book');
  });

  test('Read failures propagate instead of becoming an empty list', () async {
    failRequests = true;
    await expectLater(service.getUserRequests('test-reader'),
        throwsA(isA<PostgrestException>()));
  });

  test('Book state checks pending expiry and current loans, including overdue',
      () async {
    expect(await service.getBookBorrowingState('test-reader', 'test-book'),
        BookBorrowingState.available);
    haveRequest = true;
    expect(await service.getBookBorrowingState('test-reader', 'test-book'),
        BookBorrowingState.pending);
    haveLoan = true;
    expect(await service.getBookBorrowingState('test-reader', 'test-book'),
        BookBorrowingState.borrowed);
    final query = calls
        .lastWhere((call) => call.uri.path.endsWith('borrowing_requests'))
        .uri
        .queryParameters;
    expect(query['user_id'], 'eq.test-reader');
    expect(query['book_id'], 'eq.test-book');
    expect(query['expires_at'], startsWith('gt.'));
  });
}
