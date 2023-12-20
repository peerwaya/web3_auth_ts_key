// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyDetails _$KeyDetailsFromJson(Map<String, dynamic> json) => KeyDetails(
      pubKeyX: json['pubKeyX'] as String,
      pubKeyY: json['pubKeyY'] as String,
      requiredShares: json['requiredShares'] as int,
      threshold: json['threshold'] as int,
      totalShares: json['totalShares'] as int,
      shareDescriptions: json['shareDescriptions'] as String?,
    );

Map<String, dynamic> _$KeyDetailsToJson(KeyDetails instance) =>
    <String, dynamic>{
      'pubKeyX': instance.pubKeyX,
      'pubKeyY': instance.pubKeyY,
      'requiredShares': instance.requiredShares,
      'threshold': instance.threshold,
      'totalShares': instance.totalShares,
      'shareDescriptions': instance.shareDescriptions,
    };
