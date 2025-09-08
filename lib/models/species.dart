import 'package:json_annotation/json_annotation.dart';

part 'species.g.dart';

@JsonSerializable()
class Species {
  final String id;
  final String name;
  final String scientificName;
  final String imageQueen;
  final String imageWorker;
  final String imageMale;
  final Map<String, String> bodyColors; // region -> color
  final String description;
  final List<String> habitat;
  final String distribution;

  const Species({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.imageQueen,
    required this.imageWorker,
    required this.imageMale,
    required this.bodyColors,
    required this.description,
    required this.habitat,
    required this.distribution,
  });

  factory Species.fromJson(Map<String, dynamic> json) => _$SpeciesFromJson(json);
  Map<String, dynamic> toJson() => _$SpeciesToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Species && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Species{id: $id, name: $name}';
}

// Predefined color presets for quick selection
class ColorPreset {
  final String name;
  final Map<String, String> colors;
  final String description;

  const ColorPreset({
    required this.name,
    required this.colors,
    required this.description,
  });
}

// Available body regions for color selection
enum BodyRegion {
  head('head'),
  thorax('thorax'),
  abdomen1('abdomen1'), // First segment
  abdomen2('abdomen2'), // Second segment
  abdomen3('abdomen3'), // Third segment
  legs('legs'),
  wings('wings');

  const BodyRegion(this.value);
  final String value;
}

// Available colors for selection
enum BeeColor {
  yellow('yellow'),
  orange('orange'),
  red('red'),
  black('black'),
  white('white'),
  brown('brown'),
  gray('gray');

  const BeeColor(this.value);
  final String value;

  static BeeColor fromString(String value) {
    return BeeColor.values.firstWhere(
      (color) => color.value == value,
      orElse: () => BeeColor.black,
    );
  }
}
