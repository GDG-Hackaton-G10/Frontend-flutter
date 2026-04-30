import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../pharmacy/presentation/screens/pharmacy_dashboard_screen.dart';
import '../../../pharmacy/presentation/screens/pharmacy_profile_screen.dart';
import '../../../pharmacy_map/presentation/screens/map_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../scanner/presentation/screens/scanner_screen.dart';
import 'bento_home.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({
    super.key,
    required this.role,
    this.initialIndex = 0,
  });

  final UserRole role;
  final int initialIndex;

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    debugPrint('Bottom navigation tapped: $index');
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isPharmacy = widget.role == UserRole.pharmacy;
    final pages = <Widget>[
      isPharmacy ? const PharmacyDashboardScreen() : const BentoHomeScreen(),
      const MapScreen(),
      const _HistoryView(),
      isPharmacy ? const PharmacyProfileScreen() : const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF64748B),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: isPharmacy ? 'Dashboard' : 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: isPharmacy ? 'Pharmacy' : 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'History',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your recent scans and searches will appear here.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No scans yet! Tap the button to start.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We’ll keep your search history here for quick access.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        debugPrint('History empty-state button tapped');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ScannerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Start Scanning'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
