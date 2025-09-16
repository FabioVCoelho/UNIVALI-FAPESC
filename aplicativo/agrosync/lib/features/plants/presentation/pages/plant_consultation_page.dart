import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:agrosync/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:agrosync/features/plants/presentation/bloc/plant_event.dart';
import 'package:agrosync/features/plants/presentation/bloc/plant_state.dart';
import 'package:agrosync/features/plants/presentation/widgets/plant_details_dialog.dart';
import 'package:agrosync/features/plants/presentation/widgets/plant_edit_dialog.dart';
import 'package:agrosync/features/plants/presentation/widgets/plant_list.dart';
import 'package:agrosync/models/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrosync/core/services/rbac_service.dart';

import '../widgets/plant_filter_modal.dart';
import 'package:agrosync/features/shared/widgets/CustomChip.dart';
import 'package:agrosync/features/plants/data/models/plant_meta.dart';
import 'package:agrosync/features/plants/data/repositories/plant_meta_repository.dart';

class PlantConsultationPage extends StatefulWidget {
  const PlantConsultationPage({Key? key}) : super(key: key);

  @override
  State<PlantConsultationPage> createState() => _PlantConsultationPageState();
}

class _PlantConsultationPageState extends State<PlantConsultationPage> {
  final TextEditingController _filterDateController = TextEditingController();
  final TextEditingController _filterPastureController =
      TextEditingController();
  final TextEditingController _filterSpeciesController =
      TextEditingController();
  final TextEditingController _filterCondicaoSoloController =
      TextEditingController();
  final TextEditingController _filterCultureController =
      TextEditingController();

  // Metadata loader
  late Future<PlantMeta> _metaFuture;
  final PlantMetaRepository _metaRepo = PlantMetaRepository();

  @override
  void initState() {
    super.initState();
    context.read<PlantBloc>().add(LoadPlants());
    _metaFuture = _metaRepo.load();
    _metaRepo.refreshInBackground();
  }

  @override
  void dispose() {
    _filterDateController.dispose();
    _filterPastureController.dispose();
    _filterSpeciesController.dispose();
    _filterCondicaoSoloController.dispose();
    _filterCultureController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    showToast(message: message);
  }

  void _showPlantDetails(PlantEntity plant) {
    showDialog(
      context: context,
      builder: (context) => PlantDetailsDialog(plant: plant),
    );
  }

  void _editPlantWithMeta(PlantEntity plant, PlantMeta meta) {
    showDialog(
      context: context,
      builder: (context) => PlantEditDialog(
        plant: plant,
        speciesList: meta.species,
        conditionList: meta.conditions,
        cultureList: meta.cultures,
        onSave: (updatedPlant) {
          context.read<PlantBloc>().add(UpdatePlant(updatedPlant));
          // Re-apply current filters so the list reflects them after the update
          _filterPlants();
          _showSnackbar("Planta atualizada com sucesso!");
        },
      ),
    );
  }

  void _deletePlant(String id) {
    final firestore = FirebaseFirestore.instance;
    final email = FirebaseAuth.instance.currentUser?.email;
    Roles.canAccess(
      firestore,
      userEmail: email,
      requiredRoles: [Roles.deletePlant],
    ).then((allowed) {
      if (!allowed) {
        _showSnackbar('Acesso negado: você não possui permissão para excluir.');
        return;
      }
      context.read<PlantBloc>().add(DeletePlant(id));
      _showSnackbar("Planta removida com sucesso!");
    });
  }

  void _filterPlants() {
    context.read<PlantBloc>().add(
          FilterPlants(
            date: _filterDateController.text,
            pasture: _filterPastureController.text,
            species: _filterSpeciesController.text,
            soilCondition: _filterCondicaoSoloController.text,
            culture: _filterCultureController.text,
          ),
        );
  }

  void _clearFilters() {
    _filterDateController.clear();
    _filterPastureController.clear();
    _filterSpeciesController.clear();
    _filterCondicaoSoloController.clear();
    _filterCultureController.clear();
    _filterPlants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF388E3C),
      appBar: AppBar(
        title: const Text(
          'Consultar Plantas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF388E3C),
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Atualizar',
            onPressed: () {
              context.read<PlantBloc>().add(SyncWithFirestore());
              _showSnackbar("Lista atualizada!");
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<PlantMeta>(
          future: _metaFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar listas: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
              );
            }
            final meta = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal filter
                    FlowerListScreenWithSheet(
                      dateController: _filterDateController,
                      pastureController: _filterPastureController,
                      speciesController: _filterSpeciesController,
                      soilConditionController: _filterCondicaoSoloController,
                      cultureController: _filterCultureController,
                      speciesList: meta.species,
                      conditionList: meta.conditions,
                      cultureList: meta.cultures,
                      onSearch: () {
                        setState(() {}); // rebuild to reflect chips
                        _filterPlants();
                      },
                      onClear: () {
                        _clearFilters();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 24),

                    // Active filter chips
                    Builder(builder: (context) {
                      final chips = <Widget>[];
                      void addChip(String label, TextEditingController controller) {
                        if (controller.text.trim().isEmpty) return;
                        chips.add(
                          CustomChip(
                            label: '$label: ${controller.text}',
                            onDeleted: () {
                              setState(() {
                                controller.clear();
                              });
                              _filterPlants();
                            },
                          ),
                        );
                      }
                      addChip('Data', _filterDateController);
                      addChip('Pasto', _filterPastureController);
                      addChip('Espécie', _filterSpeciesController);
                      addChip('Condição do Solo', _filterCondicaoSoloController);
                      addChip('Cultura', _filterCultureController);
                      if (chips.isEmpty) return const SizedBox.shrink();
                      return Wrap(children: chips);
                    }),

                    const SizedBox(height: 16),

                    // Results title
                    const Text(
                      'Resultado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Plant list
                    BlocBuilder<PlantBloc, PlantState>(
                      builder: (context, state) {
                        if (state is PlantInitial) {
                          return const Center(
                              child: Text('Carregando...',
                                  style: TextStyle(color: Colors.white)));
                        } else if (state is PlantLoading) {
                          return const Center(
                              child:
                                  CircularProgressIndicator(color: Colors.white));
                        } else if (state is PlantLoaded) {
                          return state.filteredPlants.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhuma planta encontrada',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                )
                              : PlantList(
                                  plants: state.filteredPlants,
                                  onPlantTap: _showPlantDetails,
                                  onEditPlant: (p) => _editPlantWithMeta(p, meta),
                                  onDeletePlant: _deletePlant,
                                );
                        } else if (state is PlantError) {
                          return Center(
                            child: Text(
                              'Erro: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
