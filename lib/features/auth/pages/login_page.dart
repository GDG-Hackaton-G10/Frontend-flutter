import '../../../core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_hero_illustration.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../../home/presentation/screens/main_navigation_wrapper.dart';
import '../../pharmacy/presentation/screens/pharmacy_dashboard_screen.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int _roleIndex = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final loading = state.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const AuthHeroIllustration(
                icon: Icons.waving_hand_rounded,
                backgroundColor: Color(0xFF2563EB),
                iconColor: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Sign In',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in as a user or pharmacy owner.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 28),
              SegmentedButton<int>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: const Color(0xFF2563EB),
                  selectedForegroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E293B),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                segments: const [
                  ButtonSegment(value: 0, label: Text('Individual User')),
                  ButtonSegment(value: 1, label: Text('Pharmacy Owner')),
                ],
                selected: <int>{_roleIndex},
                onSelectionChanged: (newSelection) {
                  setState(() => _roleIndex = newSelection.first);
                },
              ),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(28),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'your@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        prefixIcon: Icons.mail_outline_rounded,
                        // High-contrast text and hint handled in widget
                      ),
                      const SizedBox(height: 18),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        obscureText: true,
                        validator: _validatePassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        // High-contrast text and hint handled in widget
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: loading
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage(),
                                  ),
                                ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFF2F6EF3)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthPrimaryButton(
                        label: 'Sign In',
                        loading: loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have account? ',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Keep existing _submit and _validate methods)
  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_roleIndex == 0) {
      ref
          .read(authProvider.notifier)
          .loginAsPatient(
            _emailController.text.trim(),
            'uid_${DateTime.now().millisecondsSinceEpoch}',
          );
      _showSuccessAndNavigate(
        const MainNavigationWrapper(),
        'Sign-in Successful!',
      );
    } else {
      ref
          .read(authProvider.notifier)
          .loginAsPharmacy(
            _emailController.text.trim(),
            'uid_${DateTime.now().millisecondsSinceEpoch}',
          );
      ref.read(authProvider.notifier).updateProfileStatus(true);
      _showSuccessAndNavigate(
        const PharmacyDashboardScreen(),
        'Sign-in Successful!',
      );
    }
  }

  Future<void> _showSuccessAndNavigate(
    Widget destination,
    String message,
  ) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(message),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
        ),
      );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }
}
