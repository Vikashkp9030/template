import '../../models/invoice/invoice_item_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/invoice_totals.dart';
import '../../models/invoice/tax_model.dart';
import '../errors/app_exception.dart';
import 'tax/tax_engine.dart';

class InvoiceCalculator {
  InvoiceCalculator({TaxEngine? taxEngine})
    : _taxEngine = taxEngine ?? const TaxEngine();

  final TaxEngine _taxEngine;

  InvoiceTotals calculate(InvoiceModel invoice) {
    if (invoice.items.isEmpty) {
      throw const InvoiceValidationException(
        'Invoice must contain at least one product.',
      );
    }

    final lines = <LineComputation>[];
    for (final item in invoice.items) {
      if (item.quantity <= 0) {
        throw InvoiceValidationException('Invalid quantity for ${item.sku}.');
      }
      if (item.unitPrice < 0 || item.discount < 0 || item.taxRate < 0) {
        throw InvoiceValidationException(
          'Invalid price, discount, or tax for ${item.sku}.',
        );
      }
      if (item.taxRate > 100) {
        throw InvoiceValidationException(
          'Tax rate cannot exceed 100% for ${item.sku}.',
        );
      }
      final gross = item.quantity * item.unitPrice;
      final discount = item.discountAmount;
      if (discount > gross) {
        throw InvoiceValidationException(
          'Discount exceeds line amount for ${item.sku}.',
        );
      }
      final discountedAmount = gross - discount;
      late final double taxAmount;
      late final double lineTotal;
      if (invoice.taxInclusive && item.taxRate > 0) {
        final taxable = discountedAmount / (1 + item.taxRate / 100);
        taxAmount = discountedAmount - taxable;
        lineTotal = discountedAmount;
      } else {
        taxAmount = discountedAmount * item.taxRate / 100;
        lineTotal = discountedAmount + taxAmount;
      }
      lines.add(
        LineComputation(
          item: item,
          gross: gross,
          discount: discount,
          discountedAmount: discountedAmount,
          taxAmount: taxAmount,
          lineTotal: lineTotal,
        ),
      );
    }

    final subtotal = lines.fold<double>(0, (s, l) => s + l.gross);
    final discount =
        lines.fold<double>(0, (s, l) => s + l.discount) + invoice.headerDiscount;
    final tax = lines.fold<double>(0, (s, l) => s + l.taxAmount);
    final linesTotal = lines.fold<double>(0, (s, l) => s + l.lineTotal);
    final grandTotal =
        linesTotal - invoice.headerDiscount + invoice.otherCharges + invoice.roundOff;
    final paid = invoice.payment.paidAmount;
    final balance = grandTotal - paid;

    final taxLines = _taxEngine
        .strategyFor(invoice.taxRegime)
        .breakdown(invoice: invoice, lines: lines);

    return InvoiceTotals(
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      grandTotal: grandTotal,
      paidAmount: paid,
      balanceAmount: balance,
      lines: [
        for (final line in lines)
          LineTotal(
            sku: (line.item as InvoiceItemModel).sku,
            name: (line.item as InvoiceItemModel).name,
            hsnSac: (line.item as InvoiceItemModel).hsnSac,
            quantity: (line.item as InvoiceItemModel).quantity,
            unitPrice: (line.item as InvoiceItemModel).unitPrice,
            gross: line.gross,
            discount: line.discount,
            discountedAmount: line.discountedAmount,
            taxRate: (line.item as InvoiceItemModel).taxRate,
            taxAmount: line.taxAmount,
            lineTotal: line.lineTotal,
          ),
      ],
      taxLines: [
        for (final t in taxLines)
          TaxLineTotal(
            label: t.label,
            rate: t.rate,
            taxableAmount: t.taxableAmount,
            amount: t.amount,
          ),
      ],
    );
  }
}
