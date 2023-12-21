// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initialize_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InitializeParams _$InitializeParamsFromJson(Map<String, dynamic> json) =>
    InitializeParams(
      verifierId: json['verifierId'] as String,
      verifierName: json['verifierName'] as String,
      web3AuthClientId: json['web3AuthClientId'] as String,
      idToken: json['idToken'] as String,
      network: $enumDecode(_$NetworkEnumMap, json['network']),
      chainConfig:
          ChainConfig.fromJson(json['chainConfig'] as Map<String, dynamic>),
      enableLogging: json['enableLogging'] as bool? ?? false,
      manualSync: json['manualSync'] as bool? ?? false,
      importShare: json['importShare'] as bool? ?? false,
      neverInitializeNewKey: json['neverInitializeNewKey'] as bool? ?? false,
      includeLocalMetadataTransitions:
          json['includeLocalMetadataTransitions'] as bool? ?? false,
      postBoxKey: json['postBoxKey'] as String?,
    );

Map<String, dynamic> _$InitializeParamsToJson(InitializeParams instance) =>
    <String, dynamic>{
      'postBoxKey': instance.postBoxKey,
      'enableLogging': instance.enableLogging,
      'manualSync': instance.manualSync,
      'importShare': instance.importShare,
      'neverInitializeNewKey': instance.neverInitializeNewKey,
      'includeLocalMetadataTransitions':
          instance.includeLocalMetadataTransitions,
      'network': _$NetworkEnumMap[instance.network]!,
      'web3AuthClientId': instance.web3AuthClientId,
      'verifierId': instance.verifierId,
      'verifierName': instance.verifierName,
      'idToken': instance.idToken,
      'chainConfig': instance.chainConfig,
    };

const _$NetworkEnumMap = {
  Network.mainnet: 'mainnet',
  Network.testnet: 'testnet',
  Network.cyan: 'cyan',
  Network.aqua: 'aqua',
};
