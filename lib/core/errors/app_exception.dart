sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class YamlParseException extends AppException {
  const YamlParseException(super.message, {super.cause});
}

class InvoiceValidationException extends AppException {
  const InvoiceValidationException(super.message, {super.cause});
}

class PdfGenerationException extends AppException {
  const PdfGenerationException(super.message, {super.cause});
}

class PrinterException extends AppException {
  const PrinterException(super.message, {super.cause});
}

class UnsupportedPaperSizeException extends AppException {
  const UnsupportedPaperSizeException(super.message, {super.cause});
}
