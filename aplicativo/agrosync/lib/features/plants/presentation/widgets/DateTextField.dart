import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../shared/widgets/CustomTextField.dart';

class DateTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool validator;
  final MaskTextInputFormatter inputFormatter;

  const DateTextField({
    required this.controller,
    this.validator = true,
    required this.inputFormatter,
  });

  @override
  Widget build(BuildContext context) {
    String? Function(dynamic v) validatorInput = (value) => null;
    if (validator) {
      validatorInput = (v) =>
          (v == null || v.trim().isEmpty) ? 'Este campo é obrigatório.' : null;
    }

    return Column(
      children: [
        CustomTextField(
          label: 'Data',
          controller: controller,
          hint: 'DD/MM/AAAA',
          keyboardType: TextInputType.datetime,
          validator: validatorInput,
          inputFormatters: [inputFormatter],
        )
      ],
    );
  }
}
