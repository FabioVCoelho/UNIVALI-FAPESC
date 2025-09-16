import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Widget CustomDropDownField({
  required String label,
  required TextEditingController controller,
  required List<DropdownMenuItem<String>> items,
  required String? Function(String?) validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _getDropdownValue(controller, items),
          items: items,
          onChanged: (value) {
            controller.text = value ?? '';
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: 'Selecione uma opção',
            hintStyle: const TextStyle(color: Colors.black54),
          ),
          validator: validator,
        ),
      ],
    ),
  );
}

String? _getDropdownValue(TextEditingController controller, List<DropdownMenuItem<String>> items) {
  final value = controller.text;
  if (value.isEmpty) return null;
  final exists = items.any((item) => item.value == value);
  return exists ? value : null;
}
