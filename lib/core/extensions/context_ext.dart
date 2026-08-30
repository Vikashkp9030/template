import 'package:flutter/material.dart';

extension BreakpointContext on BuildContext {
  bool get isWide => MediaQuery.sizeOf(this).width >= 900;
  bool get isCompact => MediaQuery.sizeOf(this).width < 600;
}
