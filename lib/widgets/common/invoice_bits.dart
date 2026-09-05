import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/money_formatter.dart';
import '../../models/invoice/company_model.dart';

class LogoMark extends StatelessWidget {
  const LogoMark({
    super.key,
    required this.company,
    this.size = 48,
    this.background = Colors.black87,
    this.foreground = Colors.white,
  });

  final CompanyModel company;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
      child: Text(
        company.logoLabel ?? company.initials,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'paid' => AppColors.success,
      'partial' => AppColors.warning,
      _ => AppColors.danger,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class AmountLine extends StatelessWidget {
  const AmountLine({
    super.key,
    required this.label,
    required this.value,
    required this.currency,
    this.emphasis = false,
  });

  final String label;
  final num value;
  final String currency;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: emphasis ? FontWeight.w800 : FontWeight.w500,
      fontSize: emphasis ? 16 : 12,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(MoneyFormatter.format(value, currency: currency), style: style),
        ],
      ),
    );
  }
}

class QrPlaceholder extends StatelessWidget {
  const QrPlaceholder({super.key, this.size = 72, this.caption = 'UPI / Pay'});

  final double size;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54, width: 2),
          ),
          child: CustomPaint(painter: _QrPainter()),
        ),
        const SizedBox(height: 4),
        Text(caption, style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87;
    const cells = 7;
    final w = size.width / cells;
    for (var y = 0; y < cells; y++) {
      for (var x = 0; x < cells; x++) {
        final finder = (x < 3 && y < 3) || (x > 3 && y < 3) || (x < 3 && y > 3);
        if (finder || ((x + y).isOdd && x != 3 && y != 3)) {
          canvas.drawRect(Rect.fromLTWH(x * w, y * w, w - 1, w - 1), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
