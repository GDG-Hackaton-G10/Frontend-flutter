import 'package:flutter/material.dart';

class BentoHomeScreen extends StatelessWidget {
  const BentoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bento Home')),
      body: const Center(child: Text('Welcome to Bento Home!')),
    );
  }
}
