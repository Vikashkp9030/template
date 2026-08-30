import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true).textTheme
        : ThemeData.light(useMaterial3: true).textTheme;
    return base.apply(fontFamily: 'Roboto');
  }
}
