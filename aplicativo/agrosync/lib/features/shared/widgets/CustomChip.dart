import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const CustomChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding = const EdgeInsets.only(right: 8, bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color resolvedBackground = backgroundColor ?? Colors.white;
    final Color resolvedTextColor = textColor ?? Colors.black87;
    final Color resolvedBorderColor = borderColor ?? Colors.black26;
    return Padding(
      padding: padding,
      child: Chip(
        backgroundColor: resolvedBackground,
        side: BorderSide(color: resolvedBorderColor),
        label: Text(label, style: TextStyle(color: resolvedTextColor)),
        deleteIcon: Icon(Icons.close, size: 18, color: resolvedTextColor),
        onDeleted: onDeleted,
      ),
    );
  }
}
