// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reconstruction_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReconstructionDetails _$ReconstructionDetailsFromJson(
        Map<String, dynamic> json) =>
    ReconstructionDetails(
      key: json['key'] as String,
      seedPhrase: (json['seedPhrase'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allKeys:
          (json['allKeys'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ReconstructionDetailsToJson(
        ReconstructionDetails instance) =>
    <String, dynamic>{
      'key': instance.key,
      'seedPhrase': instance.seedPhrase,
      'allKeys': instance.allKeys,
    };
