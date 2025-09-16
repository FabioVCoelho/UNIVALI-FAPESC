import 'package:flutter/material.dart';

import '../../../shared/widgets/CustomSearchableDropDown.dart';

class SpeciesSearchDropdown extends StatelessWidget {
  final TextEditingController controller;
  final List<String> species;
  final bool validator;

  const SpeciesSearchDropdown(
      {required this.controller, required this.species, this.validator = true,});

  @override
  Widget build(BuildContext context) {
    String? Function(dynamic v) validatorInput = (value) => null;
    if (validator) {
      validatorInput = (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return 'Este campo é obrigatório.';
        if (!species.contains(v)) return 'Selecione uma espécie válida.';
        return null;
      };
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomSearchableDropDown(
        label: 'Nome da espécie',
        controller: controller,
        items: species,
        validator: validatorInput,
      ),
    );
  }
}
