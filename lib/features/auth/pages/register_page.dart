import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_hero_illustration.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_screen_frame.dart';
import '../widgets/auth_text_field.dart';
import 'auth_wrapper.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _pharmacyLocationController = TextEditingController();
  bool _agreeToTerms = true;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  int _roleIndex = 0; // 0 = User, 1 = Pharmacy

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pharmacyNameController.dispose();
    _pharmacyLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final loading = state.isLoading;

    return AuthScreenFrame(
      showBackButton: true,
      child: Column(
        children: [
          const SizedBox(height: 8),
          const AuthHeroIllustration(
            icon: Icons.person_add_alt_1_rounded,
            backgroundColor: Color(0xFF2F6EF3),
            iconColor: Colors.white,
          ),
          const SizedBox(height: 14),
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                headlineMedium: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            child: const AuthBrandHeader(
              title: 'Sign Up',
              subtitle: 'Create your account as a user or pharmacy owner.',
            ),
          ),
          const SizedBox(height: 18),
          // Role toggle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Individual User')),
                ButtonSegment(value: 1, label: Text('Pharmacy Owner')),
              ],
              selected: <int>{_roleIndex},
              onSelectionChanged: (newSelection) {
                setState(() => _roleIndex = newSelection.first);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  if (_roleIndex == 1) ...[
                    AuthTextField(
                      controller: _pharmacyNameController,
                      label: 'Pharmacy Name',
                      hint: 'e.g. City Pharmacy',
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.local_pharmacy_rounded,
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _pharmacyLocationController,
                      label: 'Pharmacy Address',
                      hint: 'e.g. 123 Main St',
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                  ],
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                    prefixIcon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    obscureText: _hidePassword,
                    textInputAction: TextInputAction.next,
                    validator: _validatePassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: '••••••••',
                    obscureText: _hideConfirmPassword,
                    textInputAction: TextInputAction.done,
                    validator: _validateConfirmPassword,
                    onFieldSubmitted: (_) => _submit(),
                    prefixIcon: Icons.lock_reset_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hideConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(
                        () => _hideConfirmPassword = !_hideConfirmPassword,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: loading
                            ? null
                            : (value) => setState(
                                () => _agreeToTerms = value ?? false,
                              ),
                        activeColor: const Color(0xFF10B981),
                        checkColor: Colors.white,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Error message handling removed (no .message/.status in AuthState)
                  const SizedBox(height: 18),
                  AuthPrimaryButton(
                    label: loading ? 'Creating Account...' : 'Create Account',
                    loading: loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have account? ',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: loading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF10B981),
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
    );
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || !_agreeToTerms) return;

    final role = _roleIndex == 0 ? UserRole.patient : UserRole.pharmacy;

    try {
      await ref
          .read(authProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: role,
            name: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account Created!')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email or phone number is required';

    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    final isEmail = RegExp(pattern).hasMatch(email);
    final isPhone = RegExp(r'^[0-9+()\-\s]{7,}$').hasMatch(email);

    if (!isEmail && !isPhone)
      return 'Please enter a valid email or phone number';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }
}
