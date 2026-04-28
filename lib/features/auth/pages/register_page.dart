import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_hero_illustration.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_or_divider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_screen_frame.dart';
import '../widgets/auth_social_button.dart';

import '../widgets/auth_text_field.dart';
import '../../../home/presentation/bento_home_screen.dart';

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
  bool _agreeToTerms = true;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final loading = state.status == AuthStatus.loading;

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
          const AuthBrandHeader(
            title: 'Sign Up',
            subtitle:
                'It was popularised in the 1960s with the release of Letraset sheets containing lorem ipsum.',
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AuthSocialButton(
                        label: 'Facebook',
                        icon: Icons.facebook,
                        filled: true,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 12),
                      AuthSocialButton(
                        label: 'Google',
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const AuthOrDivider(),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'Name',
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email/Phone Number',
                    hint: 'Email/Phone Number',
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
                        activeColor: const Color(0xFF2F6EF3),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state.message != null &&
                      state.status == AuthStatus.error) ...[
                    AuthMessageBanner(message: state.message!),
                    const SizedBox(height: 12),
                  ],
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
                        'Do you have account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const BentoHomeScreen(),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text('Continue as Guest'),
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

    await ref
        .read(authControllerProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (state.status == AuthStatus.authenticated) {
      Navigator.of(context).pop();
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
