import 'package:agrosync/features/plants/data/models/plant_meta.dart';
import 'package:agrosync/features/plants/data/repositories/plant_meta_repository.dart';
import 'package:agrosync/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:agrosync/features/plants/presentation/bloc/plant_event.dart';
import 'package:agrosync/features/plants/presentation/bloc/plant_state.dart';
import 'package:agrosync/features/plants/presentation/widgets/DateTextField.dart';
import 'package:agrosync/models/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../widgets/CultureDropdown.dart';
import '../widgets/PastureDropdown.dart';
import '../widgets/QuantityTextField.dart';
import '../widgets/SoilConditionDropdown.dart';
import '../widgets/SpeciesSearchDropdown.dart';
import '../widgets/WeightFieldsRow.dart';

class PlantAddPage extends StatefulWidget {
  const PlantAddPage({Key? key}) : super(key: key);

  @override
  State<PlantAddPage> createState() => _PlantAddPageState();
}

class _PlantAddPageState extends State<PlantAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _pastureController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _cultureController = TextEditingController();
  final TextEditingController _freshWeightController = TextEditingController();
  final TextEditingController _dryWeightController = TextEditingController();

  // Masks
  final dateMask = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  final quantityMask =
      MaskTextInputFormatter(mask: '#####', filter: {"#": RegExp(r'[0-9]')});

  // Metadata loader
  late Future<PlantMeta> _metaFuture;
  final PlantMetaRepository _metaRepo = PlantMetaRepository();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _metaFuture = _metaRepo.load();
    // Try to refresh in background if online to keep cache up-to-date
    _metaRepo.refreshInBackground();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _pastureController.dispose();
    _speciesController.dispose();
    _quantityController.dispose();
    _conditionController.dispose();
    _cultureController.dispose();
    _freshWeightController.dispose();
    _dryWeightController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    showToast(message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF388E3C),
      appBar: AppBar(
        title: const Text(
          'Adicionar Planta',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF388E3C),
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      body: BlocListener<PlantBloc, PlantState>(
        listenWhen: (previous, current) =>
            current is PlantLoading ||
            current is PlantLoaded ||
            current is PlantError,
        listener: (context, state) {
          if (state is PlantLoaded) {
            _showSnackbar('Planta adicionada com sucesso!');
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            }
          }

          if (state is PlantError) {
            _showSnackbar('Erro ao salvar: ${state.message}');
          }
        },
        child: SafeArea(
          child: FutureBuilder<PlantMeta>(
            future: _metaFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar listas: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)),
                );
              }
              final meta = snapshot.data!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DateTextField(
                            controller: _dateController,
                            inputFormatter: dateMask,
                          ),
                          PastureDropdown(controller: _pastureController),
                          SpeciesSearchDropdown(
                            controller: _speciesController,
                            species: meta.species,
                          ),
                          QuantityTextField(
                            quantityController: _quantityController,
                            inputFormatter: quantityMask,
                          ),
                          SoilConditionDropdown(
                            controller: _conditionController,
                            items: meta.conditions,
                          ),
                          CultureDropdown(
                            controller: _cultureController,
                            items: meta.cultures,
                          ),
                          WeightFieldsRow(
                            freshController: _freshWeightController,
                            dryController: _dryWeightController,
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<PlantBloc, PlantState>(
                            buildWhen: (prev, curr) =>
                                (prev is PlantLoading) !=
                                (curr is PlantLoading),
                            builder: (context, state) {
                              final isLoading = state is PlantLoading;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              Navigator.pop(context, false);
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                      ),
                                      child: const Text('Cancelar'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                _savePlantData();
                                              } else {
                                                _showSnackbar(
                                                    'Por favor, preencha todos os campos obrigatórios.');
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white),
                                            )
                                          : const Text('Salvar'),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      )),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _savePlantData() async {
    final String date = _dateController.text.trim();
    final String pasture = _pastureController.text.trim();
    final String species = _speciesController.text.trim();
    final int quantity = int.parse(_quantityController.text.trim());
    final String condition = _conditionController.text.trim();
    final String culture = _cultureController.text.trim();
    final double freshWeight =
        double.tryParse(_freshWeightController.text.trim()) ?? 0.0;
    final double dryWeight =
        double.tryParse(_dryWeightController.text.trim()) ?? 0.0;

    // Dispatch request; bloc will emit PlantLoading immediately, retrieve location and complete
    context.read<PlantBloc>().add(AddPlantRequested(
          date: date,
          pasture: pasture,
          species: species,
          quantity: quantity,
          soilCondition: condition,
          culture: culture,
          freshWeight: freshWeight,
          dryWeight: dryWeight,
        ));
  }
}
