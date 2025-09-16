import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../shared/widgets/CustomTextField.dart';

class QuantityTextField extends StatelessWidget {
  final TextEditingController quantityController;
  final bool validator;
  final MaskTextInputFormatter inputFormatter;

  const QuantityTextField({
    required this.quantityController,
    this.validator = true,
    required this.inputFormatter,
  });

  String? _quantityValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'A quantidade não pode estar vazia.';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'A quantidade deve ser um número válido.';
    }

    if (quantity == 0 || quantity > 100000) {
      return 'A quantidade deve estar entre 1 e 100.000.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    String? Function(dynamic v) validatorInput = (value) => null;

    if (validator) {
      validatorInput = (v) => _quantityValidator(v);
    }

    return Column(
      children: [
        CustomTextField(
          label: 'Quantidade',
          controller: quantityController,
          hint: 'Digite a quantidade (Ex: 5)',
          keyboardType: TextInputType.number,
          validator: validatorInput,
          inputFormatters: [inputFormatter],
        )
      ],
    );
  }
}
