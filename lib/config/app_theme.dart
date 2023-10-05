import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData mainTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Color(0xFF01689D),
    secondary: Color(0xFFAEA7A7),
    secondaryContainer: Color(0xFFF7F8F8),
    tertiary: Color(0xFF01689D),
    tertiaryContainer: Color(0xFFC4C4C4),
    error: Color(0xFF822020),
  ),
  fontFamily: GoogleFonts.poppins().fontFamily,
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFF01689D),
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    labelLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    labelSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  ),

);