import 'package:equatable/equatable.dart';

class PlantEntity extends Equatable {
  final String id;
  final String date;
  final String pasture;
  final String species;
  final int quantity;
  final String soilCondition;
  final String culture;
  final double freshWeight;
  final double dryWeight;
  final double? latitude;
  final double? longitude;

  const PlantEntity({
    required this.id,
    required this.date,
    required this.pasture,
    required this.species,
    required this.quantity,
    required this.soilCondition,
    required this.culture,
    required this.freshWeight,
    required this.dryWeight,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        pasture,
        species,
        quantity,
        soilCondition,
        culture,
        freshWeight,
        dryWeight,
        latitude,
        longitude,
      ];
}