import 'package:flutter/material.dart';

import '../models/printer/thermal_paper_size.dart';

class ThermalPreviewContainer extends StatelessWidget {
  const ThermalPreviewContainer({
    super.key,
    required this.paperSize,
    required this.child,
  });

  final ThermalPaperSize paperSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: paperSize.previewWidth + 24,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
