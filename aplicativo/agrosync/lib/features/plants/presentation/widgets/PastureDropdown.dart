import 'package:flutter/material.dart';

import '../../../shared/widgets/CustomDropDownField.dart';

class PastureDropdown extends StatelessWidget {
  final TextEditingController controller;
  final bool validator;

  const PastureDropdown({required this.controller, this.validator = true});

  @override
  Widget build(BuildContext context) {
    String? Function(dynamic v) validatorInput = (value) => null;
    if (validator) {
      validatorInput = (v) =>
          (v == null || v.trim().isEmpty) ? 'Este campo é obrigatório.' : null;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomDropDownField(
        label: 'Pasto',
        controller: controller,
        items: List.generate(4, (index) {
          final value = (index + 1).toString();
          return DropdownMenuItem(
            value: value,
            child: Text('Pasto $value'),
          );
        }),
        validator: validatorInput,
      ),
    );
  }
}
