import 'package:pdf/widgets.dart' as pw;

import '../theme/document_skin.dart';

/// One block in a [BaselineStack], positioned by where its first baseline
/// must land rather than by the gap above it.
///
/// Every vertical position in the reference PDFs is a text baseline, so
/// expressing the layout this way keeps the code and the measurements in the
/// same units and makes a drift of a fraction of a point obvious.
class BaselineBlock {
  const BaselineBlock({
    required this.top,
    required this.height,
    required this.child,
    this.visible = true,
  });

  /// A run of [lineCount] lines of [size] text advancing by [step].
  factory BaselineBlock.text({
    required DocumentSkin skin,
    required double baseline,
    required double size,
    required pw.Widget child,
    int lineCount = 1,
    double? step,
    bool bold = false,
    bool visible = true,
  }) {
    final advance = step ?? skin.lineHeight(size, bold: bold);
    return BaselineBlock(
      top: baseline - skin.baselineOffset(size, bold: bold),
      height: skin.lineHeight(size, bold: bold) + (lineCount - 1) * advance,
      child: child,
      visible: visible,
    );
  }

  /// A block whose own top edge is the measured position — a rule, a filled
  /// bar or a table — rather than a baseline.
  const factory BaselineBlock.box({
    required double top,
    required double height,
    required pw.Widget child,
    bool visible,
  }) = BaselineBlock;

  /// Top edge of the block, in points from the top of the stack.
  final double top;

  final double height;
  final pw.Widget child;

  /// Whether this section has anything to print.
  ///
  /// A section with no content still declares its measured position, so the
  /// sections after it keep their own spacing and move up by exactly the room
  /// it would have taken, instead of leaving a hole where it was.
  final bool visible;

  double get bottom => top + height;
}

/// Stacks [BaselineBlock]s in flow order, inserting the exact gaps that put
/// each block at its measured offset.
///
/// Flow order matters below the item table, where the content must be able to
/// move down a page when the table grows; use [AbsoluteRegion] for the header,
/// which the references lay out at fixed coordinates.
class BaselineStack {
  const BaselineStack._();

  static pw.Widget column(
    List<BaselineBlock> blocks, {
    double origin = 0,
    pw.CrossAxisAlignment crossAxisAlignment = pw.CrossAxisAlignment.start,
  }) {
    final children = <pw.Widget>[];

    // Gaps come from the measured sequence, whether or not a block prints, so
    // each section keeps the spacing the reference gives it.
    var measured = origin;

    for (final block in blocks) {
      final gap = block.top - measured;
      measured = block.bottom > measured ? block.bottom : measured;
      if (!block.visible) continue;
      // A negative gap means two measured blocks overlap, which only happens
      // when dynamic content grew past its reference size. Collapsing to zero
      // keeps the rest of the page intact instead of throwing off the layout.
      if (gap > 0) children.add(pw.SizedBox(height: gap));
      children.add(block.child);
    }

    return pw.Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: pw.MainAxisSize.min,
      children: children,
    );
  }
}

/// A child of an [AbsoluteRegion], placed at measured coordinates.
class PlacedBlock {
  const PlacedBlock({
    required this.left,
    required this.top,
    required this.height,
    required this.child,
    this.width,
  });

  /// Text whose first baseline sits [baseline] below the region's top.
  factory PlacedBlock.text({
    required DocumentSkin skin,
    required double left,
    required double baseline,
    required double size,
    required pw.Widget child,
    double? width,
    int lineCount = 1,
    double? step,
    bool bold = false,
  }) {
    final advance = step ?? skin.lineHeight(size, bold: bold);
    return PlacedBlock(
      left: left,
      top: baseline - skin.baselineOffset(size, bold: bold),
      height: skin.lineHeight(size, bold: bold) + (lineCount - 1) * advance,
      width: width,
      child: child,
    );
  }

  final double left;
  final double top;
  final double? width;
  final double height;
  final pw.Widget child;

  double get bottom => top + height;
}

/// The fixed-coordinate header area of a document.
///
/// The reference layouts position the company block, the title, the party
/// blocks and the info rows independently of each other, so they are placed
/// rather than flowed. The region reports the height its content actually
/// needs, so the sections that follow it still move down when an address or a
/// label runs long.
class AbsoluteRegion {
  const AbsoluteRegion._();

  static pw.Widget build(List<PlacedBlock> blocks, {double minHeight = 0}) {
    if (blocks.isEmpty) return pw.SizedBox(height: minHeight);

    final height = blocks
        .map((block) => block.bottom)
        .fold<double>(minHeight, (a, b) => a > b ? a : b);

    return pw.SizedBox(
      height: height,
      child: pw.Stack(
        children: [
          for (final block in blocks)
            pw.Positioned(
              left: block.left,
              top: block.top,
              child: block.width == null
                  ? block.child
                  : pw.SizedBox(width: block.width, child: block.child),
            ),
        ],
      ),
    );
  }
}
