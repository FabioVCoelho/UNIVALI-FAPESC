import 'package:agrosync/features/plants/domain/entities/plant_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantDetailsDialog extends StatelessWidget {
  final PlantEntity plant;

  const PlantDetailsDialog({
    Key? key,
    required this.plant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF388E3C),
      title: Text(
        'Detalhes da Planta',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Espécie', plant.species),
            _infoRow('Data', plant.date),
            _infoRow('Pasto', plant.pasture),
            _infoRow('Cultura', plant.culture),
            _infoRow('Condição do Solo', plant.soilCondition),
            _infoRow('Quantidade', plant.quantity.toString()),
            _infoRow('Peso Verde', plant.freshWeight.toString()),
            _infoRow('Peso Seco', plant.dryWeight.toString()),
            _infoRow(
              'Localização',
              'Lat: ${plant.latitude?.toString() ?? "-"}, Long: ${plant.longitude?.toString() ?? "-"}',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}