import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/pages/auth_gate.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedBlue = Color(0xFF0B57D0);
    final blueScheme = ColorScheme.fromSeed(seedColor: seedBlue).copyWith(
      primary: seedBlue,
      secondary: const Color(0xFF2F6EF3),
      tertiary: const Color(0xFF4F8EF7),
      primaryContainer: const Color(0xFFD9E8FF),
      secondaryContainer: const Color(0xFFE7F0FF),
      tertiaryContainer: const Color(0xFFEAF2FF),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the red "Debug" banner
      title: 'Pharmacy App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: blueScheme,
        primaryColor: seedBlue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: blueScheme.primary,
            foregroundColor: blueScheme.onPrimary,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: blueScheme.primary,
            foregroundColor: blueScheme.onPrimary,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: blueScheme.primary,
          foregroundColor: blueScheme.onPrimary,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
