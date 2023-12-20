// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threshold_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThresholdParams _$ThresholdParamsFromJson(Map<String, dynamic> json) =>
    ThresholdParams(
      privateKey: json['privateKey'] as String,
      enableLogging: json['enableLogging'] as bool? ?? false,
      manualSync: json['manualSync'] as bool? ?? false,
      importShare: json['importShare'] as bool? ?? false,
      neverInitializeNewKey: json['neverInitializeNewKey'] as bool? ?? false,
      includeLocalMetadataTransitions:
          json['includeLocalMetadataTransitions'] as bool? ?? false,
    );

Map<String, dynamic> _$ThresholdParamsToJson(ThresholdParams instance) =>
    <String, dynamic>{
      'privateKey': instance.privateKey,
      'enableLogging': instance.enableLogging,
      'manualSync': instance.manualSync,
      'importShare': instance.importShare,
      'neverInitializeNewKey': instance.neverInitializeNewKey,
      'includeLocalMetadataTransitions':
          instance.includeLocalMetadataTransitions,
    };
