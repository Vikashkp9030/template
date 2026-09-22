import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/features/documents/document_fonts.dart';

void main() {
  // The app loads the fonts through the asset bundle rather than off disk, so
  // a missing pubspec entry would only show up at runtime.
  testWidgets('the bundled fonts load through the asset bundle', (
    tester,
  ) async {
    final fonts = await DocumentFonts.load();
    expect(fonts.sansRegular, isNotNull);
    expect(fonts.sansBold, isNotNull);
    expect(fonts.sansBoldItalic, isNotNull);
  });
}
