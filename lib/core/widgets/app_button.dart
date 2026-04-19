import 'package:flutter/material.dart';

import 'app_loading_spinner.dart';

enum AppButtonVariant { primary, outlined }

class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.fullWidth = true,
    this.leadingIcon,
  }) : variant = AppButtonVariant.primary;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.fullWidth = true,
    this.leadingIcon,
  }) : variant = AppButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final IconData? leadingIcon;
  final AppButtonVariant variant;

  bool get _isEnabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isPrimary = variant == AppButtonVariant.primary;
    final foregroundColor = isPrimary ? scheme.onPrimary : scheme.primary;
    final buttonStyle = isPrimary
        ? theme.elevatedButtonTheme.style
        : theme.outlinedButtonTheme.style?.copyWith(
            foregroundColor: WidgetStatePropertyAll(foregroundColor),
          );

    final content = _ButtonContent(
      label: label,
      loading: loading,
      foregroundColor: foregroundColor,
      leadingIcon: leadingIcon,
    );

    final button = isPrimary
        ? ElevatedButton(
            onPressed: _isEnabled ? onPressed : null,
            style: buttonStyle,
            child: content,
          )
        : OutlinedButton(
            onPressed: _isEnabled ? onPressed : null,
            style: buttonStyle,
            child: content,
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: button,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.loading,
    required this.foregroundColor,
    this.leadingIcon,
  });

  final String label;
  final bool loading;
  final Color foregroundColor;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: AppLoadingSpinner(
          size: AppSpinnerSize.small,
          color: foregroundColor,
          semanticLabel: 'Loading $label',
        ),
      );
    }

    final children = <Widget>[];
    if (leadingIcon != null) {
      children.add(Icon(leadingIcon, size: 18));
      children.add(const SizedBox(width: 8));
    }
    children.add(
      Flexible(
        child: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
