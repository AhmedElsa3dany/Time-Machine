import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff030811),
    fontFamily: 'serif',
    useMaterial3: true,
  );
}
