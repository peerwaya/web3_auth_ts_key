import 'package:web3_auth_ts_key/models/chain_config.dart';
import 'package:web3_auth_ts_key/models/enums.dart';

class InitializeParams {
  final bool enableLogging;
  final bool manualSync;
  final bool importShare;
  final bool neverInitializeNewKey;
  final bool includeLocalMetadataTransitions;
  final Network network;
  final String web3AuthClientId;
  final String verifierId;
  final String verifierName;
  final String idToken;
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
  });
}
