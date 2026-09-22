import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'features/documents/presentation/document_preview_page.dart';

void main() {
  runApp(const InvoiceTemplateApp());
}

class InvoiceTemplateApp extends StatelessWidget {
  const InvoiceTemplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Documents',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const DocumentPreviewPage(),
    );
  }
}
