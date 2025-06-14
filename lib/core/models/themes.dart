import 'package:flutter/material.dart';

var kColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color.fromARGB(255, 175, 172, 237),
  primary: const Color.fromARGB(255, 175, 172, 237),
  secondary: Colors.black,
  tertiary: const Color.fromARGB(255, 207, 207, 216),
);
var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 0, 0, 100),
  primary: const Color.fromARGB(255, 0, 0, 100),
  secondary: Colors.white,
  tertiary: const Color.fromARGB(255, 82, 82, 165),
);

final lightTheme = ThemeData().copyWith(
  brightness: Brightness.light,
  colorScheme: kColorScheme,
  textTheme: ThemeData().textTheme.copyWith(
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: kColorScheme.onSecondaryContainer,
    ),
    bodyLarge: TextStyle(
      color: kColorScheme.secondary,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(color: kColorScheme.onSecondaryContainer),
  ),
  appBarTheme: const AppBarTheme().copyWith(
    backgroundColor: kColorScheme.primaryContainer,
    foregroundColor: kColorScheme.onPrimaryContainer,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kColorScheme.primaryContainer,
      foregroundColor: kColorScheme.onPrimaryContainer,
    ),
  ),
);

final darkTheme = ThemeData.dark().copyWith(
  colorScheme: kDarkColorScheme,
  textTheme: ThemeData().textTheme.copyWith(
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: kDarkColorScheme.secondary,
    ),
    bodyLarge: TextStyle(
      color: kDarkColorScheme.secondary,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(color: kDarkColorScheme.secondary),
  ),
  appBarTheme: const AppBarTheme().copyWith(
    backgroundColor: kDarkColorScheme.primaryContainer,
    foregroundColor: kDarkColorScheme.onPrimaryContainer,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kDarkColorScheme.primaryContainer,
      foregroundColor: kDarkColorScheme.onPrimaryContainer,
    ),
  ),
);