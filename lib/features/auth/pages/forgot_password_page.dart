import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_hero_illustration.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_screen_frame.dart';
import '../widgets/auth_text_field.dart';
import 'enter_otp_page.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
            icon: Icons.pin_rounded,
            backgroundColor: Color(0xFF2F6EF3),
            iconColor: Colors.white,
          ),
          const SizedBox(height: 14),
          const AuthBrandHeader(
            title: 'Forgot Password',
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
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email ID/ Mobile Number',
                    hint: 'Email ID/ Mobile Number',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    prefixIcon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  if (state.message != null &&
                      (state.status == AuthStatus.error || state.status == AuthStatus.unauthenticated))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AuthMessageBanner(
                        message: state.message!,
                        isError: state.status == AuthStatus.error,
                      ),
                    ),
                  AuthPrimaryButton(
                    label: 'Continue',
                    loading: loading,
                    onPressed: _submit,
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
    if (!valid) return;

    await ref.read(authControllerProvider.notifier).requestPasswordReset(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EnterOtpPage(email: _emailController.text.trim()),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email ID/ Mobile Number is required';

    const emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    final isEmail = RegExp(emailPattern).hasMatch(email);
    final isPhone = RegExp(r'^[0-9+()\-\s]{7,}$').hasMatch(email);

    if (!isEmail && !isPhone) return 'Please enter a valid email or mobile number';
    return null;
  }
}
