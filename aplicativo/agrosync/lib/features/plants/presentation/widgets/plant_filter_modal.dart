import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../bloc/plant_bloc.dart';
import '../bloc/plant_event.dart';
import 'CultureDropdown.dart';
import 'package:agrosync/core/services/translation_service.dart';
import 'DateTextField.dart';
import 'PastureDropdown.dart';
import 'SoilConditionDropdown.dart';
import 'SpeciesSearchDropdown.dart';

class FlowerListScreenWithSheet extends StatefulWidget {
  final TextEditingController dateController;
  final TextEditingController pastureController;
  final TextEditingController speciesController;
  final TextEditingController soilConditionController;
  final TextEditingController cultureController;
  final List<String> speciesList;
  final List<String> conditionList;
  final List<String> cultureList;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const FlowerListScreenWithSheet({
    Key? key,
    required this.dateController,
    required this.pastureController,
    required this.speciesController,
    required this.soilConditionController,
    required this.cultureController,
    required this.speciesList,
    required this.conditionList,
    required this.cultureList,
    required this.onSearch,
    required this.onClear,
  }) : super(key: key);

  @override
  State<FlowerListScreenWithSheet> createState() =>
      _FlowerListScreenWithSheetState(
          dateController,
          pastureController,
          speciesController,
          soilConditionController,
          cultureController,
          speciesList,
          conditionList,
          cultureList,
          onSearch,
          onClear);
}

class _FlowerListScreenWithSheetState extends State<FlowerListScreenWithSheet> {
  static const _title = 'FILTER_TITLE';
  static const applyText = 'APPLY';
  final _formKey = GlobalKey<FormState>();
  final dateMask = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  final TextEditingController dateController;
  final TextEditingController pastureController;
  final TextEditingController speciesController;
  final TextEditingController soilConditionController;
  final TextEditingController cultureController;
  final List<String> speciesList;
  final List<String> conditionList;
  final List<String> cultureList;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  _FlowerListScreenWithSheetState(
      this.dateController,
      this.pastureController,
      this.speciesController,
      this.soilConditionController,
      this.cultureController,
      this.speciesList,
      this.conditionList,
      this.cultureList,
      this.onSearch,
      this.onClear);

  void _filterPlants() {
    context.read<PlantBloc>().add(
          FilterPlants(
            date: dateController.text,
            pasture: pastureController.text,
            species: speciesController.text,
            soilCondition: soilConditionController.text,
            culture: cultureController.text,
          ),
        );
  }

  void _clearFilters() {
    dateController.clear();
    pastureController.clear();
    speciesController.clear();
    soilConditionController.clear();
    cultureController.clear();
    _filterPlants();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      // isScrollControlled allows the sheet to be taller
      isScrollControlled: true,
      backgroundColor: const Color(0xFF388E3C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use a StatefulBuilder to manage the state within the sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Your filter state variables would be defined here or passed in
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TranslationService.t(_title),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Divider(),
                    DateTextField(
                      controller: dateController,
                      validator: false,
                      inputFormatter: dateMask,
                    ),
                    PastureDropdown(
                      controller: pastureController,
                      validator: false,
                    ),
                    SpeciesSearchDropdown(
                      controller: speciesController,
                      species: speciesList,
                      validator: false,
                    ),
                    SoilConditionDropdown(
                      validator: false,
                      controller: soilConditionController,
                      items: conditionList,
                    ),
                    CultureDropdown(
                      validator: false,
                      controller: cultureController,
                      items: cultureList,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Closes the modal
                              _clearFilters();
                              // Notify parent to rebuild chips and list
                              onClear();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(TranslationService.t('CLEAR_FILTERS')),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final bool isValid =
                                  _formKey.currentState!.validate();
                              if (isValid) {
                                // This part will ONLY run if the input is valid and exists in your list.
                                Navigator.of(context).pop(); // Closes the modal
                                _filterPlants();
                                // Notify parent so it can rebuild chips and list
                                onSearch();
                              }
                            },
                            child: Text(TranslationService.t(applyText)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _showFilterSheet,
      icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
      label: Text(
        TranslationService.t('FILTER'),
        style: const TextStyle(color: Colors.white),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    );
  }
}
