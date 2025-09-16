class PlantMeta {
  final List<String> species;
  final List<String> cultures;
  final List<String> conditions;

  PlantMeta({required this.species, required this.cultures, required this.conditions});

  factory PlantMeta.fromJson(Map<String, dynamic> json) {
    List<String> toList(dynamic v) => (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
    final species = toList(json['species']);
    final cultures = toList(json['cultures']);
    final conditions = toList(json['conditions']);
    // Sort alphabetically, case-insensitive
    species.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    cultures.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    // conditions keep original order (might be semantic), but we can leave as-is
    return PlantMeta(species: species, cultures: cultures, conditions: conditions);
  }
}