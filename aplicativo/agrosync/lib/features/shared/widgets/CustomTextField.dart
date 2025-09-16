import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  // Common/new API
  final TextEditingController? controller;
  final String? label; // Used as external label in legacy mode or labelText in new mode
  final String? hintText; // New API name (maps from legacy 'hint')
    final String? hint; // Legacy alias
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final InputDecoration? decoration; // Override decoration entirely when provided
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters; // Legacy support
  final AutovalidateMode? autovalidateMode; // Allow callers to opt-in

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.decoration,
    this.validator,
    this.inputFormatters,
    this.autovalidateMode,
  });

  bool get _isLegacyStyle => decoration == null && inputFormatters != null;

  @override
  Widget build(BuildContext context) {
    // If a full decoration is supplied, just use a plain TextFormField with it
    if (decoration != null && !_isLegacyStyle) {
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: decoration!,
        inputFormatters: inputFormatters,
        autovalidateMode: autovalidateMode,
      );
    }

    // Legacy styled field: external label text + filled white box
    if (_isLegacyStyle) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null)
              Text(
                label!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            if (label != null) const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hintText ?? hint,
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: suffixIcon,
              ),
              autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
              validator: validator,
              obscureText: obscureText,
            ),
          ],
        ),
      );
    }

    // Default new style: single TextFormField with labelText/hintText
    final baseDecoration = InputDecoration(
      labelText: label,
      hintText: hintText ?? hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      suffixIcon: suffixIcon,
    );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: baseDecoration,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode,
    );
  }
}
