import 'package:agrosync/features/plants/data/models/plant_model.dart';
import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PlantEditDialog extends StatefulWidget {
  final PlantEntity plant;
  final List<String> speciesList;
  final List<String> conditionList;
  final List<String> cultureList;
  final Function(PlantEntity) onSave;

  const PlantEditDialog({
    Key? key,
    required this.plant,
    required this.speciesList,
    required this.conditionList,
    required this.cultureList,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PlantEditDialog> createState() => _PlantEditDialogState();
}

class _PlantEditDialogState extends State<PlantEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController dateController;
  late final TextEditingController pastureController;
  late final TextEditingController speciesController;
  late final TextEditingController quantityController;
  late final TextEditingController soilConditionController;
  late final TextEditingController cultureController;
  late final TextEditingController freshWeightController;
  late final TextEditingController dryWeightController;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: widget.plant.date);
    pastureController = TextEditingController(text: widget.plant.pasture);
    speciesController = TextEditingController(text: widget.plant.species);
    quantityController = TextEditingController(text: widget.plant.quantity.toString());
    soilConditionController = TextEditingController(text: widget.plant.soilCondition);
    cultureController = TextEditingController(text: widget.plant.culture);
    freshWeightController = TextEditingController(text: widget.plant.freshWeight.toString());
    dryWeightController = TextEditingController(text: widget.plant.dryWeight.toString());
  }

  @override
  void dispose() {
    dateController.dispose();
    pastureController.dispose();
    speciesController.dispose();
    quantityController.dispose();
    soilConditionController.dispose();
    cultureController.dispose();
    freshWeightController.dispose();
    dryWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateMask = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

    return AlertDialog(
      backgroundColor: const Color(0xFF4B8B3B),
      title: const Text(
        'Editar planta',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Data',
                controller: dateController,
                hint: 'DD/MM/AAAA',
                keyboardType: TextInputType.datetime,
                inputFormatters: [dateMask],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A data é obrigatória';
                  }
                  return null;
                },
              ),
              _buildDropdownField(
                label: 'Pasto',
                controller: pastureController,
                items: List.generate(4, (index) {
                  final value = (index + 1).toString();
                  return DropdownMenuItem(
                    value: value,
                    child: Text('Pasto $value'),
                  );
                }),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O pasto é obrigatório';
                  }
                  return null;
                },
              ),
              _buildDropdownField(
                label: 'Nome da espécie',
                controller: speciesController,
                items: widget.speciesList
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome da espécie é obrigatório';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Quantidade',
                controller: quantityController,
                hint: 'Digite a quantidade',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A quantidade é obrigatória';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Digite um número válido';
                  }
                  return null;
                },
              ),
              _buildDropdownField(
                label: 'Condição do Solo',
                controller: soilConditionController,
                items: widget.conditionList
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A condição do solo é obrigatória';
                  }
                  return null;
                },
              ),
              _buildDropdownField(
                label: 'Cultura',
                controller: cultureController,
                items: widget.cultureList
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A cultura é obrigatória';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Peso Verde (g)',
                controller: freshWeightController,
                hint: 'Digite o peso verde',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O peso verde é obrigatório';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Digite um número válido';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Peso Seco (g)',
                controller: dryWeightController,
                hint: 'Digite o peso seco',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O peso seco é obrigatório';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Digite um número válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final base = widget.plant;
              // Preserve audit fields if available when editing
              final createdAt = (base is PlantModel) ? base.createdAt : null;
              final createdBy = (base is PlantModel) ? base.createdBy : null;
              final lastUpdated = (base is PlantModel) ? base.lastUpdated : null;
              final updatedPlant = PlantModel(
                id: widget.plant.id,
                date: dateController.text,
                pasture: pastureController.text,
                species: speciesController.text,
                quantity: int.tryParse(quantityController.text) ?? 0,
                soilCondition: soilConditionController.text,
                culture: cultureController.text,
                freshWeight: double.tryParse(freshWeightController.text) ?? 0.0,
                dryWeight: double.tryParse(dryWeightController.text) ?? 0.0,
                latitude: widget.plant.latitude,
                longitude: widget.plant.longitude,
                createdAt: createdAt,
                createdBy: createdBy,
                lastUpdated: lastUpdated,
              );
              
              widget.onSave(updatedPlant);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF388E3C),
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    List<TextInputFormatter>? inputFormatters,
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
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
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
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _getDropdownValue(controller, items),
            items: items,
            onChanged: (value) {
                          // No setState; the DropdownFormField manages its own state; we only update controller
              setState(() {
                controller.text = value ?? '';
              });
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
}