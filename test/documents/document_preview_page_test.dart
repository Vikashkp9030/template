import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/features/documents/presentation/document_preview_page.dart';
import 'package:invoice_template_preview/main.dart';
import 'package:invoice_template_preview/models/document/document_type.dart';

void main() {
  testWidgets('the app opens on the documents screen', (tester) async {
    await tester.pumpWidget(const InvoiceTemplateApp());
    await tester.pump();

    expect(find.byType(DocumentPreviewPage), findsOneWidget);
  });

  testWidgets('every document type is selectable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DocumentPreviewPage()),
    );
    await tester.pump();

    for (final type in DocumentType.values) {
      expect(
        find.text(type.displayName),
        findsWidgets,
        reason: '${type.displayName} is missing from the picker',
      );
    }
  });

  testWidgets('choosing a type retitles the screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DocumentPreviewPage()),
    );
    await tester.pump();

    expect(
      find.text('Documents — ${DocumentType.salesInvoiceTemplate1.displayName}'),
      findsOneWidget,
    );

    await tester.tap(find.text(DocumentType.packagingSlip.displayName).last);
    await tester.pump();

    expect(
      find.text('Documents — ${DocumentType.packagingSlip.displayName}'),
      findsOneWidget,
    );
  });
}
