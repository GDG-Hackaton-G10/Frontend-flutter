import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prescription_navigator/core/index.dart';

import 'features/auth/pages/auth_gate.dart';
import 'features/home/presentation/screens/bento_home.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bool authEnabled = true;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmacy App',
      theme: AppTheme.lightTheme,
      home: authEnabled ? const AuthGate() : const BentoHomeScreen(),
    );
  }
}
