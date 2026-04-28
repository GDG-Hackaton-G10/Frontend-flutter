import 'package:flutter/material.dart';

class PharmacyDashboardScreen extends StatelessWidget {
  const PharmacyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacy Dashboard')),
      body: const Center(child: Text('Welcome, Pharmacy!')),
    );
  }
}
