import 'package:flutter/material.dart';

import '../../../shared/widgets/CustomDropDownField.dart';

class SoilConditionDropdown extends StatelessWidget {
  final TextEditingController controller;
  final List<String> items;
  final bool validator;

  const SoilConditionDropdown(
      {required this.controller, required this.items, this.validator = true});

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
        label: 'Condição do Solo',
        controller: controller,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        validator: validatorInput,
      ),
    );
  }
}
