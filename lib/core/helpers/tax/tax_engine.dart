import '../../../models/invoice/invoice_item_model.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/tax_model.dart';

abstract class TaxStrategy {
  List<TaxLine> breakdown({
    required InvoiceModel invoice,
    required List<LineComputation> lines,
  });
}

class GstIndiaTaxStrategy implements TaxStrategy {
  const GstIndiaTaxStrategy();

  @override
  List<TaxLine> breakdown({
    required InvoiceModel invoice,
    required List<LineComputation> lines,
  }) {
    final byRate = <double, _Bucket>{};
    for (final line in lines) {
      final item = line.item as InvoiceItemModel;
      final bucket = byRate.putIfAbsent(item.taxRate, _Bucket.new);
      bucket.taxable += line.discountedAmount;
      bucket.tax += line.taxAmount;
    }

    final result = <TaxLine>[];
    for (final entry in byRate.entries) {
      final rate = entry.key;
      final bucket = entry.value;
      if (invoice.interState) {
        result.add(
          TaxLine(
            kind: TaxKind.igst,
            label: 'IGST ${rate.toStringAsFixed(0)}%',
            rate: rate,
            taxableAmount: bucket.taxable,
            amount: bucket.tax,
          ),
        );
      } else {
        result.add(
          TaxLine(
            kind: TaxKind.cgst,
            label: 'CGST ${(rate / 2).toStringAsFixed(1)}%',
            rate: rate / 2,
            taxableAmount: bucket.taxable,
            amount: bucket.tax / 2,
          ),
        );
        result.add(
          TaxLine(
            kind: TaxKind.sgst,
            label: 'SGST ${(rate / 2).toStringAsFixed(1)}%',
            rate: rate / 2,
            taxableAmount: bucket.taxable,
            amount: bucket.tax / 2,
          ),
        );
      }
    }
    return result;
  }
}

class VatTaxStrategy implements TaxStrategy {
  const VatTaxStrategy();

  @override
  List<TaxLine> breakdown({
    required InvoiceModel invoice,
    required List<LineComputation> lines,
  }) {
    final byRate = <double, _Bucket>{};
    for (final line in lines) {
      final item = line.item as InvoiceItemModel;
      final bucket = byRate.putIfAbsent(item.taxRate, _Bucket.new);
      bucket.taxable += line.discountedAmount;
      bucket.tax += line.taxAmount;
    }
    return [
      for (final entry in byRate.entries)
        TaxLine(
          kind: TaxKind.vat,
          label: 'VAT ${entry.key.toStringAsFixed(0)}%',
          rate: entry.key,
          taxableAmount: entry.value.taxable,
          amount: entry.value.tax,
        ),
    ];
  }
}

class NoTaxStrategy implements TaxStrategy {
  const NoTaxStrategy();

  @override
  List<TaxLine> breakdown({
    required InvoiceModel invoice,
    required List<LineComputation> lines,
  }) {
    return const [];
  }
}

class TaxEngine {
  const TaxEngine();

  TaxStrategy strategyFor(TaxRegime regime) {
    return switch (regime) {
      TaxRegime.gstIndia => const GstIndiaTaxStrategy(),
      TaxRegime.vat => const VatTaxStrategy(),
      TaxRegime.none => const NoTaxStrategy(),
    };
  }
}

class _Bucket {
  double taxable = 0;
  double tax = 0;
}
