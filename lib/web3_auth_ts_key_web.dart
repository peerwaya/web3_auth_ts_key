// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';

import 'package:js/js_util.dart' as js_util;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web3_auth_ts_key/models/initialize_params.dart';
import 'package:web3_auth_ts_key/models/key_details.dart';
import 'package:web3_auth_ts_key/models/reconstruction_details.dart';
import 'package:web3_auth_ts_key/web/core.dart';
import 'package:web3_auth_ts_key/web/solana_provider.dart';

import 'web3_auth_ts_key_platform_interface.dart';

/// A web implementation of the Web3AuthTsKeyPlatform of the Web3AuthTsKey plugin.
class Web3AuthTsKeyWeb extends Web3AuthTsKeyPlatform {
  /// Constructs a Web3AuthTsKeyWeb
  late ThresholdKeyWeb thresholdKeyWeb;
  late ServiceProviderSfaWeb serviceProvider;
  late ChainConfigWeb chainConfigWeb;
  late InitializeParams initParams;

  Web3AuthTsKeyWeb();

  static void registerWith(Registrar registrar) {
    Web3AuthTsKeyPlatform.instance = Web3AuthTsKeyWeb();
  }

  @override
  Future<void> init(InitializeParams params,
      {InitProgressCallback? progressCallback}) async {
    initParams = params;
    serviceProvider = ServiceProviderSfaWeb(
      ServiceProviderSfaWebOptions(
        enableLogging: params.enableLogging,
        postboxKey: params.postBoxKey,
        web3AuthOptions: Web3AuthOptionsWeb(
          clientId: params.web3AuthClientId,
          enableLogging: params.enableLogging,
          web3AuthNetwork: params.network.name,
        ),
      ),
    );

    chainConfigWeb = params.chainConfig.toChainConfigWeb();
    thresholdKeyWeb = ThresholdKeyWeb(
      ThresholdKeyWebOptions(
        enableLogging: params.enableLogging,
        serviceProvider: serviceProvider,
        manualSync: params.manualSync,
        storageLayer: StorageLayerWeb(
          StorageLayerWebOptions(
            hostUrl: 'https://metadata.tor.us',
            enableLogging: params.enableLogging,
          ),
        ),
        modules: ModulesWeb(
          securityQuestions: SecurityQuestionsModuleWeb(),
          webStorage: WebStorageModuleWeb(),
          //shareSerialization: ShareSerializationModuleWeb(),
        ),
      ),
    );

    final privateKeyProvider = SolanaPrivateKeyProviderWeb(
      SolanaPrivateKeyProviderOptions(
        config: SolanaPrivKeyProviderConfig(chainConfig: chainConfigWeb),
      ),
    );
    await js_util.promiseToFuture(serviceProvider.init(privateKeyProvider));
  }

  @override
  Future<String> getPostBoxKey() async {
    final oauthShare = await js_util.promiseToFuture<BN>(
      thresholdKeyWeb.serviceProvider.connect(
        SfaWebConnectOptions(
          verifier: initParams.verifierName,
          verifierId: initParams.verifierId,
          idToken: initParams.idToken,
        ),
      ),
    );
    return oauthShare.toString("hex");
  }

  @override
  Future<KeyDetails> initializeTsKey([String? privateKey]) async {
    await js_util.promiseToFuture(
      thresholdKeyWeb.initialize(
        InitializeThresholdKeyWebOptions(
          neverInitializeNewKey: initParams.neverInitializeNewKey,
        ),
      ),
    );
    return thresholdKeyWeb.getKeyDetails().toKeyDetails();
  }

  @override
  Future<ReconstructionDetails> reconstruct() async {
    final result = await js_util.promiseToFuture<ReconstructedKeyResultWeb>(
      thresholdKeyWeb.reconstructKey(),
    );
    return result.toReconstructionDetails();
  }

  @override
  Future<String> generateNewShare() async {
    final result = await js_util.promiseToFuture<GenerateNewShareResultWeb>(
        thresholdKeyWeb.generateNewShare());
    return result.newShareIndex.toString('hex');
  }

  @override
  Future<KeyDetails> deleteShare(String index) async {
    await js_util.promiseToFuture(thresholdKeyWeb.deleteShare(index));
    return thresholdKeyWeb.getKeyDetails().toKeyDetails();
  }

  @override
  Future<void> inputShare(String share) async {
    await js_util.promiseToFuture(thresholdKeyWeb.inputShare(share));
  }

  @override
  Future<String> outputShare(String index) async {
    final share =
        await js_util.promiseToFuture<BN>(thresholdKeyWeb.outputShare(index));
    return share.toString('hex');
  }

  @override
  Future<List<String>> getSharesIndexes() async {
    final shares = thresholdKeyWeb.getCurrentShareIndexes();
    return shares.cast<String>();
  }

  @override
  Future<String> generateSecurityQuestion(
      String question, String answer) async {
    final result = await js_util.promiseToFuture<GenerateNewShareResultWeb>(
        thresholdKeyWeb.modules.securityQuestions
            .generateNewShareWithSecurityQuestions(answer, question));
    return result.newShareIndex.toString("hex");
  }

  @override
  Future<void> changeSecurityQuestion(String question, String answer) async {
    await js_util.promiseToFuture(thresholdKeyWeb.modules.securityQuestions
        .changeSecurityQuestionAndAnswer(answer, question));
    return;
  }

  @override
  Future<bool> inputSecurityQuestionShare(String answer) async {
    await js_util.promiseToFuture(thresholdKeyWeb.modules.securityQuestions
        .inputShareFromSecurityQuestions(
      answer,
    ));
    return true;
  }

  // Function to map MyJsObject to KeyDetails
  KeyDetails mapMyJsObjectToKeyDetails(KeyDetailsWeb keyDetailsWeb) {
    // Extracting shareDescriptions as a JSON string
    String? shareDescriptionsJson;
    if (keyDetailsWeb.shareDescriptions != null) {
      // Assuming jsObject.shareDescriptions can be converted to a JSON string
      shareDescriptionsJson = jsonEncode(keyDetailsWeb.shareDescriptions);
    }
    return KeyDetails(
      pubKeyX: keyDetailsWeb.pubKey.x,
      pubKeyY: keyDetailsWeb.pubKey.y,
      requiredShares: keyDetailsWeb.requiredShares,
      threshold: keyDetailsWeb.threshold,
      totalShares: keyDetailsWeb.totalShares,
      shareDescriptions: shareDescriptionsJson,
    );
  }

  @override
  Future<void> dispose() async {
    return;
  }
}
