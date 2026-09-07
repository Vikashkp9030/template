import 'package:flutter/material.dart';

import '../../../core/utils/money_formatter.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../theme/invoice_template_theme.dart';

/// Line-items table shared by all three templates. Column proportions are
/// fixed `FlexColumnWidth`s (never `IntrinsicColumnWidth`) so a long
/// description can never push quantity/price/amount out of the page width —
/// the description column wraps instead.
class ItemsTableSection extends StatelessWidget {
  const ItemsTableSection({
    super.key,
    required this.theme,
    required this.lines,
    required this.currency,
  });

  final InvoiceTemplateTheme theme;
  final List<LineTotal> lines;
  final String currency;

  static const _labels = ['Description', 'Qty', 'Unit Price', 'Amount'];

  @override
  Widget build(BuildContext context) {
    final table = theme.table;
    final headerStyle = theme.type.tableHeader.flutter;
    final headerDecoration = table.headerBackground != null
        ? BoxDecoration(color: Color(table.headerBackground!))
        : BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(theme.divider), width: 1.5),
            ),
          );
    final cellPadding = EdgeInsets.symmetric(
      vertical: table.cellPaddingVertical,
      horizontal: table.cellPaddingHorizontal,
    );

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4.5),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: headerDecoration,
          children: [
            for (var i = 0; i < _labels.length; i++)
              Padding(
                padding: cellPadding,
                child: Text(
                  _labels[i].toUpperCase(),
                  textAlign: i == 0 ? TextAlign.left : TextAlign.right,
                  style: headerStyle,
                ),
              ),
          ],
        ),
        for (final item in lines)
          TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(table.rowDivider))),
            ),
            children: [
              Padding(
                padding: cellPadding,
                child: Text(
                  item.name,
                  style: theme.type.tableCellStrong.flutter,
                  softWrap: true,
                ),
              ),
              Padding(
                padding: cellPadding,
                child: Text(
                  MoneyFormatter.plain(item.quantity),
                  textAlign: TextAlign.right,
                  style: theme.type.tableCell.flutter,
                ),
              ),
              Padding(
                padding: cellPadding,
                child: Text(
                  MoneyFormatter.format(item.unitPrice, currency: currency),
                  textAlign: TextAlign.right,
                  style: theme.type.tableCell.flutter,
                ),
              ),
              Padding(
                padding: cellPadding,
                child: Text(
                  MoneyFormatter.format(item.lineTotal, currency: currency),
                  textAlign: TextAlign.right,
                  style: theme.type.tableCellStrong.flutter,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
