import 'package:flutter/material.dart';

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;

    return Row(
      children: [
        Expanded(child: Divider(color: color, thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('Or'),
        ),
        Expanded(child: Divider(color: color, thickness: 1)),
      ],
    );
  }
}
