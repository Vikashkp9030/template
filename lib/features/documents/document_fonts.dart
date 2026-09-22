import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

import '../../core/errors/app_exception.dart';

/// Loads a font file by asset key. Injectable so pure-Dart tooling and tests
/// can read the same files straight off disk without an asset bundle.
typedef FontAssetLoader = Future<ByteData> Function(String assetKey);

/// The typefaces the reference documents are set in.
///
/// Six of the eight references embed Ubuntu (regular / bold / bold-italic);
/// the packaging slip and sales return are set in Times, which the PDF format
/// provides as a standard font, so it needs no asset.
class DocumentFonts {
  const DocumentFonts({
    required this.sansRegular,
    required this.sansBold,
    required this.sansBoldItalic,
    required this.serifRegular,
    required this.serifBold,
  });

  final pw.Font sansRegular;
  final pw.Font sansBold;
  final pw.Font sansBoldItalic;
  final pw.Font serifRegular;
  final pw.Font serifBold;

  static const _ubuntuRegular = 'assets/fonts/Ubuntu-Regular.ttf';
  static const _ubuntuBold = 'assets/fonts/Ubuntu-Bold.ttf';
  static const _ubuntuBoldItalic = 'assets/fonts/Ubuntu-BoldItalic.ttf';

  /// Ubuntu metrics, shared by every Ubuntu weight (hhea ascender 932,
  /// descender -189 per 1000 units). The renderer places a baseline at
  /// `ascent * fontSize` below the top of a text box, so the templates use
  /// these to position text to the reference's exact baselines.
  static const double sansAscent = 0.932;
  static const double sansDescent = -0.189;

  /// Times metrics as the PDF standard-font tables define them. Bold has a
  /// taller ascent than regular, so a mixed-weight line is measured on bold.
  static const double serifAscent = 0.898;
  static const double serifBoldAscent = 0.935;
  static const double serifDescent = -0.218;

  static Future<DocumentFonts> load({FontAssetLoader? loader}) async {
    final read = loader ?? rootBundle.load;
    try {
      return DocumentFonts(
        sansRegular: pw.Font.ttf(await read(_ubuntuRegular)),
        sansBold: pw.Font.ttf(await read(_ubuntuBold)),
        sansBoldItalic: pw.Font.ttf(await read(_ubuntuBoldItalic)),
        serifRegular: pw.Font.times(),
        serifBold: pw.Font.timesBold(),
      );
    } catch (error, stack) {
      Error.throwWithStackTrace(
        PdfGenerationException(
          'Unable to load the document fonts. Check that the Ubuntu font '
          'files are bundled under assets/fonts/.',
          cause: error,
        ),
        stack,
      );
    }
  }

  /// Falls back to the built-in Helvetica family when the Ubuntu assets are
  /// unavailable, so a document still renders rather than failing outright.
  static DocumentFonts fallback() {
    return DocumentFonts(
      sansRegular: pw.Font.helvetica(),
      sansBold: pw.Font.helveticaBold(),
      sansBoldItalic: pw.Font.helveticaBoldOblique(),
      serifRegular: pw.Font.times(),
      serifBold: pw.Font.timesBold(),
    );
  }
}
