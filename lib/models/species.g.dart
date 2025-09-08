// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Species _$SpeciesFromJson(Map<String, dynamic> json) => Species(
  id: json['id'] as String,
  name: json['name'] as String,
  scientificName: json['scientificName'] as String,
  imageQueen: json['imageQueen'] as String,
  imageWorker: json['imageWorker'] as String,
  imageMale: json['imageMale'] as String,
  bodyColors: Map<String, String>.from(json['bodyColors'] as Map),
  description: json['description'] as String,
  habitat: (json['habitat'] as List<dynamic>).map((e) => e as String).toList(),
  distribution: json['distribution'] as String,
);

Map<String, dynamic> _$SpeciesToJson(Species instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'scientificName': instance.scientificName,
  'imageQueen': instance.imageQueen,
  'imageWorker': instance.imageWorker,
  'imageMale': instance.imageMale,
  'bodyColors': instance.bodyColors,
  'description': instance.description,
  'habitat': instance.habitat,
  'distribution': instance.distribution,
};
