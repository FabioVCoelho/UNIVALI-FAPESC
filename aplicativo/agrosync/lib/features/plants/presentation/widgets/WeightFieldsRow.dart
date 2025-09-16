import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/CustomTextField.dart';

class WeightFieldsRow extends StatelessWidget {
  final TextEditingController freshController;
  final TextEditingController dryController;
  final bool validator;

  const WeightFieldsRow({
    required this.freshController,
    required this.dryController,
    this.validator = true,
  });

  String? _optionalWeightValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    final weight = double.tryParse(value);
    if (weight != null) {
      if (weight < 0 || weight > 1000000) {
        return 'O peso deve estar entre 0 g e 1.000.000 g.';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    String? Function(dynamic v) validatorInput = (value) => null;

    if (validator) {
      validatorInput = (v) => _optionalWeightValidator(v);
    }

    return Column(
      children: [
        CustomTextField(
          label: 'Peso Verde (g)',
          controller: freshController,
          hint: 'Ex: 345.67',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: validatorInput,
          inputFormatters: [SingleDotNumberFormatter()],
        ),
        CustomTextField(
          label: 'Peso Seco (g)',
          controller: dryController,
          hint: 'Ex: 145.67',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: validatorInput,
          inputFormatters: [SingleDotNumberFormatter()],
        ),
      ],
    );
  }
}

//TODO: Validar qual dos 2 formatter são melhores.
class SingleDotNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    // Only digits and at most one dot, unlimited decimals
    final singleDot = RegExp(r'^\d*\.?\d*$');
    if (!singleDot.hasMatch(text)) {
      return oldValue;
    }
    return newValue;
  }
}

class WeightInputFormatter extends TextInputFormatter {
  final int maxDecimals;

  WeightInputFormatter({this.maxDecimals = 2}) : assert(maxDecimals >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow empty while typing
    if (text.isEmpty) return newValue;

    // Only digits and at most one dot
    final singleDot = RegExp(r'^\d*\.?\d*$');
    if (!singleDot.hasMatch(text)) {
      return oldValue;
    }

    // Limit decimals
    if (maxDecimals >= 0 && text.contains('.')) {
      final parts = text.split('.');
      final decimals = parts.length > 1 ? parts[1] : '';
      if (decimals.length > maxDecimals) {
        return oldValue;
      }
    }

    return newValue;
  }
}
