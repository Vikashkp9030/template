import 'package:flutter/material.dart';

import '../core/constants/app_radius.dart';
import '../models/printer/paper_size.dart';

/// Frames the live Flutter-widget template render at its true page
/// dimensions and lets the viewer pan/zoom it — it never clips or crops
/// content the way a fixed-height box would. With enough line items the
/// document naturally grows taller than one page; that full height stays
/// visible (scroll/zoom to see it) instead of being silently cut off, which
/// is what the PDF (and its real pagination) is the authority for.
///
/// The page is initially scaled to fit the available width so it isn't
/// oversized on a small viewport, without distorting its aspect ratio —
/// the viewer can then zoom in/out and pan freely.
class InvoicePreviewContainer extends StatefulWidget {
  const InvoicePreviewContainer({
    super.key,
    required this.paperSize,
    required this.child,
  });

  final InvoicePaperSize paperSize;
  final Widget child;

  @override
  State<InvoicePreviewContainer> createState() => _InvoicePreviewContainerState();
}

class _InvoicePreviewContainerState extends State<InvoicePreviewContainer> {
  final _controller = TransformationController();
  double? _fittedForWidth;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fitToWidth(double availableWidth) {
    if (_fittedForWidth == availableWidth || availableWidth <= 0) return;
    _fittedForWidth = availableWidth;
    final scale = (availableWidth / widget.paperSize.width).clamp(0.1, 1.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.value = (Matrix4.identity()..scale(scale, scale, 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _fitToWidth(constraints.maxWidth);
        return ClipRect(
          child: InteractiveViewer(
            constrained: false,
            minScale: 0.1,
            maxScale: 3,
            boundaryMargin: const EdgeInsets.all(64),
            transformationController: _controller,
            child: Container(
              width: widget.paperSize.width,
              constraints: BoxConstraints(minHeight: widget.paperSize.height),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
