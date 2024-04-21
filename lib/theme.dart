import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  fontFamily: '',
  /* textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
  ), */
  appBarTheme: const AppBarTheme(
    color: Colors.blue,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
);

ThemeData darkTheme = ThemeData(
  textTheme: GoogleFonts.ralewayTextTheme().apply(bodyColor: Colors.white),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 88, 102, 185),
    brightness: Brightness.dark,
  ),
);
