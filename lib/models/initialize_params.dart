import 'package:json_annotation/json_annotation.dart';
import 'package:web3_auth_ts_key/models/chain_config.dart';
import 'package:web3_auth_ts_key/models/enums.dart';

part 'initialize_params.g.dart';

@JsonSerializable()
class InitializeParams {
  final String? postBoxKey;
  final bool enableLogging;
  final bool manualSync;
  final bool importShare;
  final String? importKey;
  final bool neverInitializeNewKey;
  final bool includeLocalMetadataTransitions;
  final Network network;
  final String web3AuthClientId;
  final String verifierId;
  final String verifierName;
  final String idToken;
  final String? webInitialUrl;
  final ChainConfig chainConfig;

  InitializeParams({
    required this.verifierId,
    required this.verifierName,
    required this.web3AuthClientId,
    required this.idToken,
    required this.network,
    required this.chainConfig,
    this.enableLogging = false,
    this.manualSync = false,
    this.importShare = false,
    this.neverInitializeNewKey = false,
    this.includeLocalMetadataTransitions = false,
    this.postBoxKey,
    this.webInitialUrl,
    this.importKey,
  });

  factory InitializeParams.fromJson(Map<String, dynamic> json) =>
      _$InitializeParamsFromJson(json);

  Map<String, dynamic> toJson() => _$InitializeParamsToJson(this);
}
