import 'package:flutter/material.dart';

enum AppSpinnerSize { small, large }

class AppLoadingSpinner extends StatelessWidget {
  const AppLoadingSpinner({
    super.key,
    this.size = AppSpinnerSize.small,
    this.text,
    this.color,
    this.semanticLabel,
  });

  final AppSpinnerSize size;
  final String? text;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spinnerColor = color ?? scheme.primary;
    final spinnerDiameter = size == AppSpinnerSize.small ? 18.0 : 30.0;
    final spinnerStrokeWidth = size == AppSpinnerSize.small ? 2.0 : 2.8;

    final spinner = SizedBox(
      width: spinnerDiameter,
      height: spinnerDiameter,
      child: CircularProgressIndicator(
        strokeWidth: spinnerStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
      ),
    );

    if (text == null) {
      return Semantics(label: semanticLabel ?? 'Loading', child: spinner);
    }

    return Semantics(
      label: semanticLabel ?? text,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          spinner,
          const SizedBox(height: 12),
          Text(
            text!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
