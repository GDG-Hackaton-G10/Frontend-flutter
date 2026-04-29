import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../auth/pages/login_page.dart';
import 'package:smart_prescription_navigator/core/index.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final email = authState.email ?? 'No email available';
    final role = authState.role;
    final roleLabel = _roleLabel(role);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFF2563EB),
              child: Text(
                _initialFromEmail(email),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              roleLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              email,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 28),
          Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.badge_outlined,
                color: Color(0xFF2563EB),
              ),
              title: const Text('Role'),
              subtitle: Text(roleLabel),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(top: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.email_outlined,
                color: Color(0xFF2563EB),
              ),
              title: const Text('Email'),
              subtitle: Text(email),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(top: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle app appearance'),
              value: ref.watch(themeModeProvider) == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setDarkMode(value);
              },
              secondary: const Icon(
                Icons.dark_mode_outlined,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(height: 36),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_rounded,
              color: Color(0xFF64748B),
            ),
            title: const Text('Legal & Privacy'),
            onTap: () => _showInfoDialog(
              context,
              title: 'Legal & Privacy',
              message: 'Legal and privacy information goes here.',
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFF64748B),
            ),
            title: const Text('Help & Support'),
            onTap: () => _showInfoDialog(
              context,
              title: 'Help & Support',
              message: 'Help and support information goes here.',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            onPressed: () {
              debugPrint('User logout tapped');
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  static String _initialFromEmail(String email) {
    if (email.isEmpty) return '?';
    return email[0].toUpperCase();
  }

  static String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return 'Guest';
      case UserRole.patient:
        return 'Individual User';
      case UserRole.pharmacy:
        return 'Pharmacy Owner';
    }
  }

  static void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
