import 'dart:math' as math;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:library_management/localization/app_localization.dart';

class BorrowingTicket extends StatelessWidget {
  const BorrowingTicket({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    if (!RegExp(r'^[0-9]{8}$').hasMatch(code)) {
      return Text(AppLocalization.tr('loan_invalid_pass'));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final width = math.min(constraints.maxWidth, 400.0);
          return Container(
            width: width,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              BarcodeWidget(
                key: const ValueKey('pickup-qr'),
                barcode: Barcode.qrCode(),
                data: code,
                width: math.min(192, width - 40),
                height: math.min(192, width - 40),
                drawText: false,
                padding: const EdgeInsets.all(32),
                color: Colors.black,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 32),
              BarcodeWidget(
                key: const ValueKey('pickup-barcode'),
                barcode: Barcode.code128(),
                data: code,
                width: width - 40,
                height: 88,
                drawText: false,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.black,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              FittedBox(
                child: SelectableText(
                  code,
                  key: const ValueKey('pickup-code'),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Colors.black,
                  ),
                ),
              ),
            ]),
          );
        }),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.copy),
          label: Text(AppLocalization.tr('loan_copy')),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalization.tr('loan_copied'))),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(AppLocalization.tr('loan_pass_hint'), textAlign: TextAlign.center),
      ],
    );
  }
}

Future<void> showBorrowingTicket(
  BuildContext context, {
  required String code,
  String? bookTitle,
}) =>
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(title: Text(AppLocalization.tr('loan_pass'))),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                if (bookTitle != null) ...[
                  Text(bookTitle,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                ],
                BorrowingTicket(code: code),
              ]),
            ),
          ),
        ),
      ),
    );
