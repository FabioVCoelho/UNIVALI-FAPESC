import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:agrosync/features/plants/data/models/plant_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantList extends StatefulWidget {
  final List<PlantEntity> plants;
  final Function(PlantEntity) onPlantTap;
  final Function(PlantEntity) onEditPlant;
  final Function(String) onDeletePlant;

  const PlantList({
    Key? key,
    required this.plants,
    required this.onPlantTap,
    required this.onEditPlant,
    required this.onDeletePlant,
  }) : super(key: key);

  @override
  State<PlantList> createState() => _PlantListState();
}

class _PlantListState extends State<PlantList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      color: Colors.white,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.plants.length,
          itemBuilder: (context, index) {
            final plant = widget.plants[index];
            final species = plant.species;
            final date = plant.date;

            final isModel = plant is PlantModel;
            final conflict = isModel && (plant).status == 'sync_conflict';
            final needsSync = isModel && (plant).needsSync;

            return ListTile(
              leading: const Icon(Icons.grass, color: Colors.black),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      species,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (conflict)
                    const Tooltip(
                      message: 'Conflito de sincronização: aguarda revisão do admin',
                      child: Icon(Icons.report_problem, color: Colors.orange),
                    )
                  else if (needsSync)
                    const Tooltip(
                      message: 'Alterações pendentes para sincronizar',
                      child: Icon(Icons.sync_problem, color: Colors.blueGrey),
                    ),
                ],
              ),
              subtitle: Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              onTap: () {
                widget.onPlantTap(plant);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () {
                      widget.onEditPlant(plant);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      widget.onDeletePlant(plant.id);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}