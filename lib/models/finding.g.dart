// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Finding _$FindingFromJson(Map<String, dynamic> json) => Finding(
  id: json['id'] as String,
  species: Species.fromJson(json['species'] as Map<String, dynamic>),
  type: json['type'] as String,
  notes: json['notes'] as String,
  imagePath: json['imagePath'] as String?,
  date: DateTime.parse(json['date'] as String),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  locationName: json['locationName'] as String?,
);

Map<String, dynamic> _$FindingToJson(Finding instance) => <String, dynamic>{
  'id': instance.id,
  'species': instance.species,
  'type': instance.type,
  'notes': instance.notes,
  'imagePath': instance.imagePath,
  'date': instance.date.toIso8601String(),
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'locationName': instance.locationName,
};
