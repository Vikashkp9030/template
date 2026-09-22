import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/invoice_template_preview.dart';

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

  test('the package-qualified key is tried before the bare one', () {
    // A host app bundles these under packages/<name>/, and that is the normal
    // case — asking for the bare path there is a 404.
    expect(DocumentFonts.assetKeys('Ubuntu-Regular.ttf'), [
      'packages/invoice_template_preview/assets/fonts/Ubuntu-Regular.ttf',
      'assets/fonts/Ubuntu-Regular.ttf',
    ]);
  });

  test('a host that drops the assets gets told which keys were tried', () async {
    await expectLater(
      DocumentFonts.load(loader: (_) async => throw 'HTTP 404'),
      throwsA(
        isA<PdfGenerationException>()
            .having((e) => e.message, 'message', contains('packages/'))
            .having((e) => e.message, 'message', contains('Ubuntu-Regular')),
      ),
    );
  });
}
