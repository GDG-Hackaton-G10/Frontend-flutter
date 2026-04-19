import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/main_entry_screen.dart';
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
import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (!mounted) {
        return;
      }

      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainEntryScreen()),
          (route) => false,
        );
      }
    });

    final state = ref.watch(authControllerProvider);
    final loading = state.status == AuthStatus.loading;
    final theme = Theme.of(context);

    return AuthScreenFrame(
      showBackButton: true,
      child: Column(
        children: [
          const SizedBox(height: 8),
          const AuthHeroIllustration(
            icon: Icons.waving_hand_rounded,
            backgroundColor: Color(0xFF2F6EF3),
            iconColor: Colors.white,
          ),
          const SizedBox(height: 14),
          const AuthBrandHeader(
            title: 'Sign In',
            subtitle:
                'It was popularised in the 1960s with the release of Letraset sheets containing lorem ipsum.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 28,
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
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'solaiman51544@gmail.com',
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
                    obscureText: true,
                    validator: _validatePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    prefixIcon: Icons.lock_outline_rounded,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              );
                            },
                      child: const Text('Forgot Password'),
                    ),
                  ),
                  if (state.message != null &&
                      (state.status == AuthStatus.error ||
                          state.status == AuthStatus.unauthenticated)) ...[
                    AuthMessageBanner(
                      message: state.message!,
                      isError: state.status == AuthStatus.error,
                    ),
                    const SizedBox(height: 12),
                  ],
                  AuthPrimaryButton(
                    label: 'Sign In',
                    loading: loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have account? ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: loading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                        child: Text(
                          'Sign Up',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
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
    if (!valid) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }

    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
