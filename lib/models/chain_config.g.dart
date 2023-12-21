// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChainConfig _$ChainConfigFromJson(Map<String, dynamic> json) => ChainConfig(
      chainNamespace: json['chainNamespace'] as String,
      chainId: json['chainId'] as String,
      rpcTarget: json['rpcTarget'] as String,
      displayName: json['displayName'] as String,
      blockExplorer: json['blockExplorer'] as String,
      ticker: json['ticker'] as String,
      tickerName: json['tickerName'] as String,
    );

Map<String, dynamic> _$ChainConfigToJson(ChainConfig instance) =>
    <String, dynamic>{
      'chainNamespace': instance.chainNamespace,
      'chainId': instance.chainId,
      'rpcTarget': instance.rpcTarget,
      'displayName': instance.displayName,
      'blockExplorer': instance.blockExplorer,
      'ticker': instance.ticker,
      'tickerName': instance.tickerName,
    };
