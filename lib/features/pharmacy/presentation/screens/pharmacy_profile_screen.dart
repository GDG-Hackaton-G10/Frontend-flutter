import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../auth/pages/login_page.dart';

class PharmacyProfileScreen extends ConsumerStatefulWidget {
  const PharmacyProfileScreen({super.key});

  @override
  ConsumerState<PharmacyProfileScreen> createState() =>
      _PharmacyProfileScreenState();
}

class _PharmacyProfileScreenState extends ConsumerState<PharmacyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _pharmacyNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _contactController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    _pharmacyNameController = TextEditingController(
      text: authState.role == UserRole.pharmacy
          ? 'Central Pharmacy'
          : 'Pharmacy Name',
    );
    _locationController = TextEditingController(text: 'Main Street, City');
    _contactController = TextEditingController(
      text: authState.email ?? '+1 555 0100',
    );
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _pharmacyNameController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final roleLabel = authState.role == UserRole.pharmacy
        ? 'Pharmacy Owner'
        : 'Account';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pharmacy Profile'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => debugPrint('Pharmacy profile action tapped'),
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            _HeaderCard(
              roleLabel: roleLabel,
              email: authState.email ?? 'No email available',
            ),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Edit Profile',
              subtitle: 'Update the public-facing pharmacy details.',
            ),
            const SizedBox(height: 12),
            _FieldCard(
              controller: _pharmacyNameController,
              label: 'Pharmacy Name',
              hint: 'Enter pharmacy name',
              icon: Icons.storefront_rounded,
            ),
            const SizedBox(height: 12),
            _FieldCard(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter location',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 12),
            _FieldCard(
              controller: _contactController,
              label: 'Contact Info',
              hint: 'Phone or email',
              icon: Icons.call_outlined,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 28),
            _SectionTitle(
              title: 'Settings',
              subtitle: 'Security, legal, and app info.',
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.lock_reset_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    title: const Text('Update Password'),
                    subtitle: const Text(
                      'Change your pharmacy account password',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showUpdatePasswordDialog(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: Color(0xFF2563EB),
                    ),
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('Read how your data is handled'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showInfoDialog(
                      title: 'Privacy Policy',
                      message:
                          'Dummy privacy policy text. Replace this with your real privacy policy when the backend is ready.',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.article_outlined,
                      color: Color(0xFF2563EB),
                    ),
                    title: const Text('Terms of Service'),
                    subtitle: const Text('Review app usage rules'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showInfoDialog(
                      title: 'Terms of Service',
                      message:
                          'Dummy terms of service text. Replace this with your real terms when the backend is ready.',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    title: const Text('About'),
                    subtitle: const Text('App version and developer info'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showInfoDialog(
                      title: 'About',
                      message:
                          'Smart Prescription Navigator\nVersion 1.0.0\nBuilt by GDG Hackaton G10',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _confirmLogout,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    debugPrint('Save Changes tapped');
    debugPrint('Pharmacy Name: ${_pharmacyNameController.text.trim()}');
    debugPrint('Location: ${_locationController.text.trim()}');
    debugPrint('Contact Info: ${_contactController.text.trim()}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pharmacy profile updated successfully.'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  void _showUpdatePasswordDialog() {
    debugPrint('Update Password tapped');
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            hintText: 'Enter new password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('Update Password cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint(
                'Password updated: ${_passwordController.text.trim()}',
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Password update requested.')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog({required String title, required String message}) {
    debugPrint('$title tapped');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('$title dialog closed');
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    debugPrint('Logout tapped');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to logout from the pharmacy account?'),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('Logout cancelled');
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint('Logout confirmed');
              Navigator.pop(dialogContext);
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.roleLabel, required this.email});

  final String roleLabel;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_pharmacy_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Settings-ready pharmacy profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
      ],
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }
}
