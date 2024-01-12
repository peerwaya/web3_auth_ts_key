import 'package:js/js.dart';
import 'package:web3_auth_ts_key/models/chain_config.dart';
import 'package:web3_auth_ts_key/models/key_details.dart';
import 'package:web3_auth_ts_key/models/reconstruction_details.dart';

@JS()
@anonymous
class CustomAuthArgsWeb {
  external String get network;
  external String get web3AuthClientId;
  external String get baseUrl;
  external bool get enableLogging;
  external factory CustomAuthArgsWeb({
    String network,
    String web3AuthClientId,
    String baseUrl,
    bool enableLogging,
  });
}

@JS()
@anonymous
class ServiceProviderWebOptions {
  external bool get useTSS;
  external CustomAuthArgsWeb get customAuthArgs;
  external factory ServiceProviderWebOptions({
    bool useTSS,
    CustomAuthArgsWeb customAuthArgs,
  });
}

@JS()
@anonymous
class ServiceProviderWebInitOptions {
  external factory ServiceProviderWebInitOptions({
    bool skipInit,
  });
}

@JS('ServiceProviderTorus.TorusServiceProvider')
class ServiceProviderWeb {
  external factory ServiceProviderWeb(ServiceProviderWebOptions options);
  external dynamic init(dynamic privateKeyProvider);
}

@JS()
@anonymous
class StorageLayerWebOptions {
  external String get hostUrl;
  external bool get enableLogging;
  external factory StorageLayerWebOptions({
    String hostUrl,
    bool enableLogging,
  });
}

@JS('StorageLayerTorus.TorusStorageLayer')
class StorageLayerWeb {
  external factory StorageLayerWeb(StorageLayerWebOptions options);
}

@JS('ShareSerialization.ShareSerializationModule')
class ShareSerializationModuleWeb {
  external factory ShareSerializationModuleWeb();
}

@JS('SecurityQuestions.SecurityQuestionsModule')
class SecurityQuestionsModuleWeb {
  external factory SecurityQuestionsModuleWeb();
  external Future<GenerateNewShareResultWeb>
      generateNewShareWithSecurityQuestions(
          String answerString, String questions);
  external Future<void> inputShareFromSecurityQuestions(String answerString);
  external Future<void> changeSecurityQuestionAndAnswer(
      String answerString, String questions);
}

@JS('WebStorage.WebStorageModule')
class WebStorageModuleWeb {
  external factory WebStorageModuleWeb();
}

@JS()
@anonymous
class ServiceProviderSfaWebOptions {
  external String get clientId;
  external String? get postboxKey;
  external bool get enableLogging;
  external factory ServiceProviderSfaWebOptions({
    Web3AuthOptionsWeb web3AuthOptions,
    String? postboxKey,
    bool enableLogging,
  });
}

@JS()
@anonymous
class Web3AuthOptionsWeb {
  external String get clientId;
  external String get web3AuthNetwork;
  external bool get enableLogging;
  external factory Web3AuthOptionsWeb({
    String clientId,
    String web3AuthNetwork,
    bool enableLogging,
  });
}

@JS()
@anonymous
class SfaWebConnectOptions {
  external String get verifier;
  external String get verifierId;
  external String get idToken;
  external factory SfaWebConnectOptions({
    String verifier,
    String verifierId,
    String idToken,
  });
}

@JS('ServiceProviderSfa.SfaServiceProvider')
class ServiceProviderSfaWeb {
  external factory ServiceProviderSfaWeb(ServiceProviderSfaWebOptions options);
  external dynamic init(dynamic privateKeyProvider);
  external BN connect(SfaWebConnectOptions options);
}

@JS()
@anonymous
class ModulesWeb {
  external ShareSerializationModuleWeb get shareSerialization;
  external SecurityQuestionsModuleWeb get securityQuestions;
  external WebStorageModuleWeb get webStorage;
  external factory ModulesWeb(
      {ShareSerializationModuleWeb shareSerialization,
      SecurityQuestionsModuleWeb securityQuestions,
      WebStorageModuleWeb webStorage});
}

@JS()
@anonymous
class ThresholdKeyWebOptions {
  external bool get enableLogging;
  external ServiceProviderSfaWeb get serviceProvider;
  external StorageLayerWeb get storageLayer;
  external ModulesWeb get modules;
  external bool get manualSync;
  external bool get serverTimeOffset;
  external factory ThresholdKeyWebOptions({
    bool enableLogging,
    ServiceProviderSfaWeb serviceProvider,
    StorageLayerWeb storageLayer,
    bool manualSync,
    ModulesWeb modules,
    num? serverTimeOffset,
  });
}

@JS()
@anonymous
class InitializeThresholdKeyWebOptions {
  external bool? get neverInitializeNewKey;
  external factory InitializeThresholdKeyWebOptions({
    bool? neverInitializeNewKey,
    BN? importKey,
  });
}

@JS('Core.default')
class ThresholdKeyWeb {
  external ServiceProviderSfaWeb get serviceProvider;
  external StorageLayerWeb get storageLayer;
  external ModulesWeb get modules;
  external factory ThresholdKeyWeb(ThresholdKeyWebOptions options);
  external dynamic initialize([InitializeThresholdKeyWebOptions? options]);
  external KeyDetailsWeb getKeyDetails();
  external Future<ReconstructedKeyResultWeb> reconstructKey(
      [bool? reconstructKeyMiddleware]);
  external dynamic generateNewShare();
  external dynamic deleteShare(String index);
  external dynamic inputShare(String share, [String? type]);
  external dynamic outputShare(String shareIndex, [String? type]);
  external List<dynamic> getCurrentShareIndexes();
  external dynamic syncLocalMetadataTransitions();
  external dynamic CRITICAL_deleteTkey();
}

enum ChainNameSpaces { eip155, solana, other }

@JS()
@anonymous
class ChainConfigWeb {
  external ChainNameSpaces get chainNamespace;
  external String get chainId;
  external String get rpcTarget;
  external String get displayName;
  external String get blockExplorer;
  external String get ticker;
  external String get tickerName;
  external factory ChainConfigWeb({
    String chainNamespace,
    String chainId,
    String rpcTarget,
    String displayName,
    String blockExplorer,
    String ticker,
    String tickerName,
  });
}

@JS()
@anonymous
class BN {
  @override
  external String toString([String? str]);
}

@JS()
@anonymous
class KeyDetailsWeb {
  external factory KeyDetailsWeb({
    PublicKeyWeb pubKey,
    int requiredShares,
    int threshold,
    int totalShares,
    dynamic
        shareDescriptions, // Using dynamic type for complex nested structure
  });

  external PublicKeyWeb get pubKey;
  external int get requiredShares;
  external int get threshold;
  external int get totalShares;
  external dynamic
      get shareDescriptions; // Using dynamic type for complex nested structure
}

@JS()
@anonymous
class PublicKeyWeb {
  external factory PublicKeyWeb({String x, String y});

  external String get x;
  external String get y;
}

@JS()
@anonymous
class ShareDescriptionWeb {
  external factory ShareDescriptionWeb(
      {String module, String userAgent, int dateAdded, String questions});

  external String get module;
  external String get userAgent;
  external int get dateAdded;
  external String get questions;
}

@JS('JSON.stringify')
external String stringify(dynamic data);

extension KeyDetailWebExt on KeyDetailsWeb {
  KeyDetails toKeyDetails() {
    // Extracting shareDescriptions as a JSON string
    String? shareDescriptionsJson;
    if (shareDescriptions != null) {
      // Assuming jsObject.shareDescriptions can be converted to a JSON string
      shareDescriptionsJson = stringify(shareDescriptions);
    }
    return KeyDetails(
      pubKeyX: pubKey.x,
      pubKeyY: pubKey.y,
      requiredShares: requiredShares,
      threshold: threshold,
      totalShares: totalShares,
      shareDescriptions: shareDescriptionsJson,
    );
  }
}

@JS()
@anonymous
class ReconstructedKeyResultWeb {
  external factory ReconstructedKeyResultWeb({
    BN privKey,
    List<BN>? seedPhrase,
    List<BN>? allKeys,
  });
  external BN get privKey;
  external List<BN>? get seedPhrase;
  external List<BN>? get allKeys;
}

extension ReconstructedKeyResultWebExt on ReconstructedKeyResultWeb {
  ReconstructionDetails toReconstructionDetails() {
    return ReconstructionDetails(
      key: privKey.toString('hex'),
      seedPhrase: seedPhrase?.map((i) => i.toString("hex")).toList() ?? [],
      allKeys: allKeys?.map((i) => i.toString("hex")).toList() ?? [],
    );
  }
}

@JS()
@anonymous
class GenerateNewShareResultWeb {
  external factory GenerateNewShareResultWeb({
    BN newShareIndex,
  });
  external BN get newShareIndex;
}

extension ChainConfigWebExt on ChainConfig {
  ChainConfigWeb toChainConfigWeb() {
    return ChainConfigWeb(
      chainId: chainId,
      rpcTarget: rpcTarget,
      chainNamespace: chainNamespace,
      blockExplorer: blockExplorer,
      displayName: displayName,
      ticker: ticker,
      tickerName: tickerName,
    );
  }
}

@JS()
@anonymous
class ShareStoreWeb {
  external factory ShareStoreWeb();
  external ShareWeb get share;
  external String toJSON();
  external static ShareStoreWeb fromJSON(String shareStore);
}

@JS()
@anonymous
class ShareWeb {
  external factory ShareWeb();
  external BN get share;
}
