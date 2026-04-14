import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Scanner Screen')),
    const Center(child: Text('Map Screen')),
    const Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Pharmacies'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
