// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html show window;

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
  Web3AuthTsKeyWeb();

  static void registerWith(Registrar registrar) {
    Web3AuthTsKeyPlatform.instance = Web3AuthTsKeyWeb();
  }

  @override
  Future<KeyDetails> initialize(InitializeParams params) async {
    final serviceProvider = ServiceProviderSfaWeb(
      ServiceProviderSfaWebOptions(
        clientId: params.web3AuthClientId,
        enableLogging: params.enableLogging,
        web3AuthNetwork: params.network.name,
      ),
    );
    final chainConfigWeb = ChainConfigWeb(
        chainId: params.chainConfig.chainId,
        rpcTarget: params.chainConfig.rpcTarget,
        chainNamespace: params.chainConfig.chainNamespace,
        blockExplorer: params.chainConfig.blockExplorer,
        displayName: params.chainConfig.displayName,
        ticker: params.chainConfig.ticker,
        tickerName: params.chainConfig.tickerName);
    final privateKeyProvider = SolanaPrivateKeyProviderWeb(
      SolanaPrivateKeyProviderOptions(
        config: SolanaPrivKeyProviderConfig(chainConfig: chainConfigWeb),
      ),
    );
    thresholdKeyWeb = ThresholdKeyWeb(
      ThresholdKeyWebOptions(
        enableLogging: params.enableLogging,
        serviceProvider: serviceProvider,
      ),
    );

    await js_util.promiseToFuture(
        thresholdKeyWeb.serviceProvider.init(privateKeyProvider));
    final oauthShare = await js_util.promiseToFuture<BN>(
      thresholdKeyWeb.serviceProvider.connect(
        SfaWebConnectOptions(
          verifier: params.verifierName,
          verifierId: params.verifierId,
          idToken: params.idToken,
        ),
      ),
    );
    print("oauthShare: ${oauthShare.toString("hex")}");
    await js_util.promiseToFuture(
      thresholdKeyWeb.initialize(),
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
    return await js_util
        .promiseToFuture<String>(thresholdKeyWeb.outputShare(index));
  }

  @override
  Future<List<String>> getSharesIndexes() async {
    return thresholdKeyWeb.getCurrentShareIndexes();
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
  Future<bool> changeSecurityQuestion(String question, String answer) async {
    final result = await js_util.promiseToFuture<bool>(thresholdKeyWeb
        .modules.securityQuestions
        .changeSecurityQuestionAndAnswer(answer, question));
    return result;
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
}
