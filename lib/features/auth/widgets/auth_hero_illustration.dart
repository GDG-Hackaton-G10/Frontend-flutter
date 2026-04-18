import 'package:flutter/material.dart';

class AuthHeroIllustration extends StatelessWidget {
  const AuthHeroIllustration({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            top: 22,
            child: _bubble(backgroundColor.withValues(alpha: 0.18), 88),
          ),
          Positioned(
            right: 18,
            top: 40,
            child: _bubble(const Color(0xFFBFD7FF), 72),
          ),
          Positioned(
            bottom: 26,
            left: 52,
            child: _bubble(const Color(0xFFE7F0FF), 54),
          ),
          Container(
            width: 182,
            height: 182,
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 56),
          ),
          Positioned(
            top: 20,
            right: 52,
            child: _sparkle(const Color(0xFF2F6EF3)),
          ),
          Positioned(
            bottom: 28,
            right: 42,
            child: _sparkle(const Color(0xFF7EA7F7)),
          ),
        ],
      ),
    );
  }

  Widget _bubble(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _sparkle(Color color) {
    return Icon(Icons.auto_awesome, color: color, size: 28);
  }
}
