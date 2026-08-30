import 'package:flutter/material.dart';

import '../core/constants/app_radius.dart';
import '../models/printer/paper_size.dart';

class InvoicePreviewContainer extends StatelessWidget {
  const InvoicePreviewContainer({
    super.key,
    required this.paperSize,
    required this.child,
  });

  final InvoicePaperSize paperSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: FittedBox(
            child: Container(
              width: paperSize.width,
              height: paperSize.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRect(child: child),
            ),
          ),
        );
      },
    );
  }
}
