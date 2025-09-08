import 'package:json_annotation/json_annotation.dart';
import 'species.dart';

part 'finding.g.dart';

@JsonSerializable()
class Finding {
  final String id;
  final Species species;
  final String type; // queen, worker, male, or custom
  final String notes;
  final String? imagePath;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String? locationName;

  const Finding({
    required this.id,
    required this.species,
    required this.type,
    required this.notes,
    this.imagePath,
    required this.date,
    required this.latitude,
    required this.longitude,
    this.locationName,
  });

  factory Finding.fromJson(Map<String, dynamic> json) => _$FindingFromJson(json);
  Map<String, dynamic> toJson() => _$FindingToJson(this);

  Finding copyWith({
    String? id,
    Species? species,
    String? type,
    String? notes,
    String? imagePath,
    DateTime? date,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return Finding(
      id: id ?? this.id,
      species: species ?? this.species,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Finding && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Finding{id: $id, species: ${species.name}, type: $type}';
}

// Available bee types
enum BeeType {
  queen('Queen'),
  worker('Worker'),
  male('Male'),
  unknown('Unknown');

  const BeeType(this.displayName);
  final String displayName;

  static BeeType fromString(String value) {
    return BeeType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => BeeType.unknown,
    );
  }
}
