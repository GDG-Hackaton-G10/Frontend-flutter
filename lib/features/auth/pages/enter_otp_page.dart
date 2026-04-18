import 'package:flutter/material.dart';

import '../widgets/auth_brand_header.dart';
import '../widgets/auth_hero_illustration.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_screen_frame.dart';
import 'reset_password_page.dart';

class EnterOtpPage extends StatefulWidget {
  const EnterOtpPage({super.key, required this.email});

  final String email;

  @override
  State<EnterOtpPage> createState() => _EnterOtpPageState();
}

class _EnterOtpPageState extends State<EnterOtpPage> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            title: 'Enter OTP',
            subtitle: 'Enter the OTP code we just sent you on your registered Email',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return _OtpCell(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(height: 18),
                AuthPrimaryButton(
                  label: 'Reset Password',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final otp = _controllers.map((e) => e.text).join();
    if (otp.length < 4) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ResetPasswordPage(),
      ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD3DFF5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD3DFF5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2F6EF3), width: 1.4),
          ),
        ),
      ),
    );
  }
}
