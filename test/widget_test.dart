import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_management/localization/app_localization.dart';
import 'package:library_management/presentation/screens/home/pages/borrows_page.dart';
import 'package:library_management/presentation/widgets/borrowing_ticket.dart';
import 'support/borrowing_fixtures.dart';

void main() {
  tearDown(() => AppLocalization.notifier.value = AppLanguage.zh);

  test(
      'Pending requests expire at the deadline, approved requests retain status',
      () {
    final deadline = DateTime.utc(2026, 11, 10, 9);
    final request = requestFixture(expiry: deadline);
    expect(request.statusAt(deadline.subtract(const Duration(milliseconds: 1))),
        'pending');
    expect(request.statusAt(deadline), 'expired');
    expect(
        requestFixture(status: 'approved', expiry: deadline).statusAt(deadline),
        'approved');
  });

  test('Loans overdue by less than a day are overdue and count as one day', () {
    final loan = loanFixture();
    expect(loan.isCurrent, isTrue);
    expect(loan.isOverdueAt(DateTime.now()), isTrue);
    expect(loan.daysFromDue(DateTime.now()), 1);
    expect(
        loanFixture(status: 'returned').isOverdueAt(DateTime.now()), isFalse);
  });

  for (final language in AppLanguage.values) {
    for (final width in [320.0, 428.0]) {
      for (final dark in [false, true]) {
        testWidgets(
            'Pass $language at $width px, dark=$dark preserves scannable contrast',
            (tester) async {
          tester.view.physicalSize = Size(width, 860);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          AppLocalization.notifier.value = language;
          await tester.pumpWidget(MaterialApp(
              theme: dark ? ThemeData.dark() : ThemeData.light(),
              home: const Scaffold(
                  body: SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: BorrowingTicket(code: '12345678')))));
          await tester.pumpAndSettle();
          final barcodes = tester
              .widgetList<BarcodeWidget>(find.byType(BarcodeWidget))
              .toList();
          expect(barcodes, hasLength(2));
          expect(barcodes.map((barcode) => String.fromCharCodes(barcode.data)),
              everyElement('12345678'));
          expect(barcodes.map((barcode) => barcode.backgroundColor),
              everyElement(Colors.white));
          expect(barcodes.map((barcode) => barcode.color),
              everyElement(Colors.black));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }

  testWidgets('Malformed passes do not draw a barcode', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: BorrowingTicket(code: 'https://example.com'))));
    expect(find.byType(BarcodeWidget), findsNothing);
    expect(find.text('凭证格式无效，请刷新记录。'), findsOneWidget);
  });

  testWidgets('Readers display a pass and cancel a request after confirmation',
      (tester) async {
    final service = MemoryBorrowingService();
    await tester.pumpWidget(MaterialApp(home: BorrowsPage(service: service)));
    await tester.pumpAndSettle();
    expect(find.text('待管理员确认'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('show-pass-request-test')));
    await tester.pumpAndSettle();
    expect(find.text('12345678'), findsOneWidget);
    expect(find.byType(BarcodeWidget), findsNWidgets(2));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消申请'));
    await tester.pumpAndSettle();
    expect(service.cancelled, 0);
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();
    expect(service.cancelled, 1);
    expect(find.text('暂无待确认的借阅申请'), findsOneWidget);
    await tester.tap(find.text('历史记录'));
    await tester.pumpAndSettle();
    expect(find.text('已取消'), findsOneWidget);
    expect(find.byKey(const ValueKey('show-pass-request-test')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Closing a pass reloads staff approval and return state',
      (tester) async {
    final service = MemoryBorrowingService();
    await tester.pumpWidget(MaterialApp(home: BorrowsPage(service: service)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('show-pass-request-test')));
    await tester.pumpAndSettle();
    service.requests = [
      requestFixture(status: 'approved', loanId: 'loan-test')
    ];
    service.loans = [loanFixture()];
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('暂无待确认的借阅申请'), findsOneWidget);
    expect(find.text('取消申请'), findsNothing);
    await tester.tap(find.text('历史记录'));
    await tester.pumpAndSettle();
    expect(find.text('已确认借出'), findsOneWidget);
    await tester.tap(find.text('当前借阅'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('show-pass-request-test')));
    await tester.pumpAndSettle();
    service.loans = [loanFixture(status: 'returned')];
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('暂无借阅中的图书'), findsOneWidget);
    await tester.tap(find.text('历史记录'));
    await tester.pumpAndSettle();
    expect(find.text('已归还'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Expired requests hide pass and cancellation actions',
      (tester) async {
    final service = MemoryBorrowingService()
      ..requests = [
        requestFixture(
            expiry: DateTime.now().subtract(const Duration(minutes: 1)))
      ];
    await tester.pumpWidget(MaterialApp(home: BorrowsPage(service: service)));
    await tester.pumpAndSettle();
    expect(find.text('暂无待确认的借阅申请'), findsOneWidget);
    await tester.tap(find.text('历史记录'));
    await tester.pumpAndSettle();
    expect(find.text('已过期'), findsOneWidget);
    expect(find.text('取消申请'), findsNothing);
    expect(find.byKey(const ValueKey('show-pass-request-test')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Load failures show retry instead of a false empty list',
      (tester) async {
    final service = MemoryBorrowingService()..failLoad = true;
    await tester.pumpWidget(MaterialApp(home: BorrowsPage(service: service)));
    await tester.pumpAndSettle();
    expect(find.text('借阅记录加载失败，请重试。'), findsOneWidget);
    expect(find.text('暂无待确认的借阅申请'), findsNothing);
    service.failLoad = false;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('待管理员确认'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Current loans retain their pass but readers cannot self-return',
      (tester) async {
    final service = MemoryBorrowingService()
      ..requests = [requestFixture(status: 'approved', loanId: 'loan-test')]
      ..loans = [loanFixture()];
    await tester.pumpWidget(MaterialApp(home: BorrowsPage(service: service)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('当前借阅'));
    await tester.pumpAndSettle();
    expect(find.text('已逾期'), findsOneWidget);
    expect(find.text('请携带图书到馆，由管理员确认归还。'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('show-pass-request-test')), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '归还图书'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final language in AppLanguage.values) {
    testWidgets('Borrowing tabs separate request and loan states in $language',
        (tester) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      AppLocalization.notifier.value = language;
      String t(String key) => AppLocalization.tr(key);
      final service = MemoryBorrowingService()
        ..requests = [
          requestFixture(id: 'pending'),
          requestFixture(
              id: 'approved', status: 'approved', loanId: 'borrowed'),
          requestFixture(id: 'cancelled', status: 'cancelled'),
          requestFixture(id: 'rejected', status: 'rejected'),
          requestFixture(
              id: 'expired',
              expiry: DateTime.now().subtract(const Duration(minutes: 1))),
        ]
        ..loans = [
          loanFixture(
              id: 'borrowed', due: DateTime.now().add(const Duration(days: 1))),
          loanFixture(id: 'overdue', status: 'overdue'),
          loanFixture(id: 'lost', status: 'lost'),
          loanFixture(id: 'returned', status: 'returned'),
        ];
      await tester.pumpWidget(MaterialApp(home: BorrowsPage(service: service)));
      await tester.pumpAndSettle();
      expect(find.text(t('loan_pending')), findsOneWidget);
      for (final status in [
        'approved',
        'cancelled',
        'rejected',
        'expired',
        'borrowed',
        'overdue',
        'lost',
        'returned'
      ]) {
        expect(find.text(t('loan_$status')), findsNothing);
      }

      await tester.tap(find.text(t('current_borrow')));
      await tester.pumpAndSettle();
      for (final status in ['borrowed', 'overdue', 'lost']) {
        expect(find.text(t('loan_$status')), findsOneWidget);
      }
      for (final status in [
        'pending',
        'approved',
        'cancelled',
        'rejected',
        'expired',
        'returned'
      ]) {
        expect(find.text(t('loan_$status')), findsNothing);
      }
      expect(find.byKey(const ValueKey('show-pass-approved')), findsOneWidget);

      await tester.tap(find.text(t('history_record')));
      await tester.pumpAndSettle();
      for (final status in [
        'approved',
        'cancelled',
        'rejected',
        'expired',
        'returned'
      ]) {
        expect(find.text(t('loan_$status')), findsOneWidget);
      }
      for (final status in ['pending', 'borrowed', 'overdue', 'lost']) {
        expect(find.text(t('loan_$status')), findsNothing);
      }
      expect(find.text(t('loan_show_pass')), findsNothing);
      expect(find.text(t('loan_cancel_request')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
