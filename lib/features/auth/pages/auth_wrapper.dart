import '../../../core/providers/auth_provider.dart';
import '../../../core/auth/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/screens/bento_home.dart';
import '../../home/presentation/screens/main_navigation_wrapper.dart';
import '../../pharmacy/presentation/screens/pharmacy_dashboard_screen.dart';
import '../pages/login_page.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    switch (authState.role) {
      case UserRole.guest:
        return const _GuestOrUserNav(isGuest: true);
      case UserRole.patient:
        return const MainNavigationWrapper();
      case UserRole.pharmacy:
        return const PharmacyDashboardScreen();
    }
  }
}

// BottomNavigationBar for Guest/User
class _GuestOrUserNav extends StatefulWidget {
  final bool isGuest;
  const _GuestOrUserNav({required this.isGuest});

  @override
  State<_GuestOrUserNav> createState() => _GuestOrUserNavState();
}

class _GuestOrUserNavState extends State<_GuestOrUserNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (widget.isGuest && index != 0) {
      // Show sign-in nudge
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text('Sign in to access this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const BentoHomeScreen(),
      // TODO: Replace with actual HistoryScreen
      const Scaffold(body: Center(child: Text('History Page'))),
      // TODO: Replace with actual ProfileScreen
      const Scaffold(body: Center(child: Text('Profile Page'))),
    ];
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Guest landing with nudge dialog
class _GuestLandingWithNudge extends StatefulWidget {
  const _GuestLandingWithNudge();
  @override
  State<_GuestLandingWithNudge> createState() => _GuestLandingWithNudgeState();
}

class _GuestLandingWithNudgeState extends State<_GuestLandingWithNudge> {
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text('Welcome!'),
            content: const Text('Sign in to track your history.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const BentoHomeScreen();
  }
}
