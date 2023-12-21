import 'package:json_annotation/json_annotation.dart';

part 'chain_config.g.dart';

@JsonSerializable()
class ChainConfig {
  final String chainNamespace;
  final String chainId;
  final String rpcTarget;
  final String displayName;
  final String blockExplorer;
  final String ticker;
  final String tickerName;

  ChainConfig({
    required this.chainNamespace,
    required this.chainId,
    required this.rpcTarget,
    required this.displayName,
    required this.blockExplorer,
    required this.ticker,
    required this.tickerName,
  });

  factory ChainConfig.fromJson(Map<String, dynamic> json) =>
      _$ChainConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ChainConfigToJson(this);
}
