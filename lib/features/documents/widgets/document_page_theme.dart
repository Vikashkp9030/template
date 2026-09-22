import 'package:pdf/widgets.dart' as pw;

import '../theme/document_geometry.dart';
import '../theme/document_palette.dart';
import '../theme/document_skin.dart';

/// Page chrome shared by the reference layouts: the frame the bordered
/// templates draw around the whole page, the rule the A4 spreadsheet
/// templates put above the footer, and the page number bottom-right.
///
/// The offsets below are measured from the page edges, exactly as they were
/// read off the reference PDFs. The renderer anchors a page background at the
/// top-left of the content box rather than of the page, so they are shifted by
/// the margins on the way out.
class DocumentPageTheme {
  const DocumentPageTheme._();

  static const double pageNumberSize = 7.99;

  /// The frame and the footer rule both run wider than the content box.
  static const double chromeLeft = 39.60;
  static const double chromeRight = 566.63;

  static pw.PageTheme build({
    required DocumentGeometry geometry,
    required DocumentSkin skin,
    required double contentTop,
    required double contentBottom,
    bool frame = false,
    bool footerRule = false,
    double? pageNumberBaseline,
    double? pageNumberRight,
  }) {
    final hasChrome =
        frame || footerRule || pageNumberBaseline != null;

    return pw.PageTheme(
      pageFormat: geometry.pageFormat,
      margin: pw.EdgeInsets.fromLTRB(
        geometry.left,
        contentTop,
        geometry.rightMargin,
        geometry.height - contentBottom,
      ),
      buildBackground: hasChrome
          ? (context) => pw.Stack(
              children: [
                // Origin correction: the background is anchored at the
                // content box, not the page.
                // Four fills rather than a stroked box: a stroke straddles
                // the content edge and the renderer clips the outer half of
                // it away. This is also how the reference draws the frame.
                if (frame) ...[
                  for (final top in [0.0, contentBottom - contentTop - 0.75])
                    pw.Positioned(
                      left: chromeLeft - geometry.left,
                      top: top,
                      child: pw.Container(
                        width: chromeRight - chromeLeft,
                        height: 0.75,
                        color: DocumentPalette.frame,
                      ),
                    ),
                  for (final left in [
                    chromeLeft - geometry.left,
                    chromeRight - geometry.left - 0.75,
                  ])
                    pw.Positioned(
                      left: left,
                      top: 0,
                      child: pw.Container(
                        width: 0.75,
                        height: contentBottom - contentTop,
                        color: DocumentPalette.frame,
                      ),
                    ),
                ],
                if (footerRule)
                  pw.Positioned(
                    left: chromeLeft - geometry.left,
                    top: contentBottom - contentTop,
                    child: pw.Container(
                      width: chromeRight - chromeLeft,
                      height: 0.75,
                      color: DocumentPalette.rule,
                    ),
                  ),
                if (pageNumberBaseline != null)
                  pw.Positioned(
                    left: -geometry.left,
                    top: pageNumberBaseline -
                        skin.baselineOffset(pageNumberSize) -
                        contentTop,
                    child: pw.SizedBox(
                      width: pageNumberRight ?? geometry.right,
                      child: pw.Text(
                        '${context.pageNumber}',
                        textAlign: pw.TextAlign.right,
                        style: skin.style(
                          size: pageNumberSize,
                          color: DocumentPalette.pageNumber,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : null,
    );
  }
}
