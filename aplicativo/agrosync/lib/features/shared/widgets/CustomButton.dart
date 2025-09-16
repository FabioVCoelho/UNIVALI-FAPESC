import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool primary;
  final double height;
  final ButtonStyle? style;

  const CustomButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.primary = true,
    this.height = 56,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = ElevatedButton.styleFrom(
      backgroundColor: primary ? theme.colorScheme.primary : Colors.grey,
      foregroundColor: Colors.white,
      minimumSize: Size(double.infinity, height),
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style ?? defaultStyle,
        child: child ?? Text(label ?? ''),
      ),
    );
  }
}
