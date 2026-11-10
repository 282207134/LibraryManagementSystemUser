import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/models/book_model.dart';
import 'package:library_management/data/models/borrow_record_model.dart';
import 'package:library_management/data/models/borrow_request_model.dart';
import 'package:library_management/data/services/borrowing_service.dart';
import 'package:library_management/localization/app_localization.dart';
import 'package:library_management/presentation/widgets/borrowing_ticket.dart';
import 'package:library_management/utils/error_localization.dart';
import 'package:library_management/utils/image_helper.dart';

class BorrowsPage extends StatefulWidget {
  const BorrowsPage({super.key, this.service});
  final BorrowingService? service;

  @override
  State<BorrowsPage> createState() => _BorrowsPageState();
}

class _BorrowsPageState extends State<BorrowsPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _service = widget.service ?? BorrowingService();
  late final TabController _tabs;
  final Map<String, String?> _covers = {};
  List<BorrowRequest> _requests = [];
  List<BorrowRecord> _loans = [];
  bool _loading = true;
  String? _error, _action;
  int _loadVersion = 0;
  Timer? _clock;
  DateTime _now = DateTime.now();

  String t(String key) => AppLocalization.tr(key);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final version = ++_loadVersion;
    setState(() {
      _loading = true;
      _error = null;
    });
    final userId = _service.currentUserId;
    try {
      if (userId == null) {
        _requests = [];
        _loans = [];
        return;
      }
      final result = await Future.wait([
        _service.getUserRequests(userId),
        _service.getUserBorrowings(userId),
      ]);
      final requests = result[0] as List<BorrowRequest>;
      final loans = result[1] as List<BorrowRecord>;
      final books = [
        ...requests.map((r) => r.book),
        ...loans.map((r) => r.book)
      ];
      final covers = <String, String?>{};
      for (final book in books.whereType<Book>()) {
        if (book.coverImageUrl == null || covers.containsKey(book.id)) continue;
        try {
          covers[book.id] =
              await ImageHelper.resolveCoverImageUrl(book.coverImageUrl);
        } catch (_) {
          covers[book.id] = null;
        }
      }
      if (!mounted ||
          version != _loadVersion ||
          userId != _service.currentUserId) {
        return;
      }
      setState(() {
        _requests = requests;
        _loans = loans;
        _covers
          ..clear()
          ..addAll(covers);
        _now = DateTime.now();
      });
    } catch (_) {
      if (mounted && version == _loadVersion) {
        setState(() => _error = t('loan_load_failed'));
      }
    } finally {
      if (mounted && version == _loadVersion) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(BorrowRequest request) async {
    if (_action != null) return;
    setState(() => _action = request.id);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t('loan_cancel_request')),
          content: Text(t('loan_cancel_confirm')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t('cancel'))),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t('confirm'))),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      final result = await _service.cancelRequest(request.id);
      if (result['success'] != true) {
        throw StateError(result['error'] as String? ?? t('loan_action_failed'));
      }
      if (mounted) await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ErrorLocalization.getLocalizedErrorMessage(error)),
      ));
    } finally {
      if (mounted) setState(() => _action = null);
    }
  }

  String date(String raw) {
    final parsed = DateTime.tryParse(raw)?.toLocal();
    if (parsed == null) return '-';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${parsed.year}-${two(parsed.month)}-${two(parsed.day)} ${two(parsed.hour)}:${two(parsed.minute)}';
  }

  Widget _bookInfo(String id, Book? book) => InkWell(
        onTap: () => context.push('/book/$id'),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 48,
              height: 68,
              child: _covers[id] == null
                  ? const Icon(Icons.menu_book, size: 40)
                  : CachedNetworkImage(
                      imageUrl: _covers[id]!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.menu_book))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(book?.title ?? t('loan_unknown_book'),
                    style: Theme.of(context).textTheme.titleMedium),
                if (book?.author != null) Text(book!.author),
              ])),
        ]),
      );

  Widget _status(String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(t('loan_$value'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ['overdue', 'expired', 'rejected', 'lost'].contains(value)
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            )),
      );

  Widget _card(List<Widget> children) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );

  Widget _detail(String label, String value) => Text('${t(label)}: $value');

  Widget _showPass(BorrowRequest request) => OutlinedButton.icon(
        key: ValueKey('show-pass-${request.id}'),
        icon: const Icon(Icons.qr_code),
        label: Text(t('loan_show_pass')),
        onPressed: () async {
          await showBorrowingTicket(context,
              code: request.pickupCode, bookTitle: request.book?.title);
          if (mounted) await _load();
        },
      );

  Widget _requestCard(BorrowRequest request) {
    final status = request.statusAt(_now);
    return _card([
      _bookInfo(request.bookId, request.book),
      _status(status),
      _detail('loan_request_date', date(request.createdAt.toIso8601String())),
      if (status == 'pending')
        _detail('loan_expiry', date(request.expiresAt.toIso8601String())),
      if (request.reviewNote?.isNotEmpty == true)
        _detail('loan_note', request.reviewNote!),
      if (status == 'pending')
        Wrap(spacing: 12, children: [
          _showPass(request),
          if (status == 'pending')
            TextButton(
              onPressed: _action == null ? () => _cancel(request) : null,
              child: Text(t('loan_cancel_request')),
            ),
        ]),
    ]);
  }

  Widget _loanCard(BorrowRecord loan) {
    final overdue = loan.isOverdueAt(_now);
    final requests = _requests.where((r) => r.borrowingId == loan.id);
    return _card([
      _bookInfo(loan.bookId, loan.book),
      _status(overdue ? 'overdue' : loan.status),
      _detail('loan_borrowed_date', date(loan.borrowedAt)),
      _detail(
          loan.status == 'returned' ? 'loan_returned_date' : 'loan_due',
          date(loan.status == 'returned'
              ? loan.returnedAt ?? ''
              : loan.dueDate)),
      if (loan.isCurrent) ...[
        _detail(overdue ? 'loan_days_overdue' : 'loan_days_left',
            '${loan.daysFromDue(_now)}'),
        const SizedBox(height: 12),
        Text(t('loan_return_hint')),
        if (requests.isNotEmpty) _showPass(requests.first),
      ],
    ]);
  }

  Widget _list(Iterable<Widget> cards, String emptyKey) => RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (cards.isEmpty) ...[
              const SizedBox(height: 80),
              const Icon(Icons.menu_book_outlined, size: 48),
              const SizedBox(height: 16),
              Center(child: Text(t(emptyKey))),
            ] else
              ...cards,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(t('borrows')),
          actions: [
            IconButton(
              tooltip: t('loan_refresh'),
              onPressed: _loading || _action != null ? null : _load,
              icon: const Icon(Icons.refresh),
            )
          ],
          bottom: TabBar(
            controller: _tabs,
            tabs: [
              Tab(text: t('loan_requests')),
              Tab(text: t('current_borrow')),
              Tab(text: t('history_record'))
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: _load, child: Text(t('loan_retry'))),
                    ]),
                  ))
                : Column(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Text(t('loan_policy'))),
                    Expanded(
                        child: TabBarView(controller: _tabs, children: [
                      _list(
                          _requests
                              .where((r) => r.statusAt(_now) == 'pending')
                              .map(_requestCard),
                          'loan_empty_requests'),
                      _list(_loans.where((r) => r.isOutstanding).map(_loanCard),
                          'loan_empty_current'),
                      _list([
                        ..._requests
                            .where((r) => r.statusAt(_now) != 'pending')
                            .map(_requestCard),
                        ..._loans.where((r) => !r.isOutstanding).map(_loanCard),
                      ], 'loan_empty_history'),
                    ])),
                  ]),
      );
}
