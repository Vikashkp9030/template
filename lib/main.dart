import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'features/preview/invoice_preview_page.dart';

void main() {
  runApp(const InvoiceTemplateApp());
}

class InvoiceTemplateApp extends StatelessWidget {
  const InvoiceTemplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice Template Preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const InvoicePreviewPage(),
    );
  }
}
