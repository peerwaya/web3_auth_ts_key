import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web3_auth_ts_key/models/enums.dart';
import 'package:web3_auth_ts_key/models/initialize_params.dart';
import 'package:web3_auth_ts_key/models/key_details.dart';
import 'package:web3_auth_ts_key/models/reconstruction_details.dart';
import 'package:web3_auth_ts_key/models/threshold_params.dart';
import 'package:customauth_flutter/customauth_flutter.dart';

import 'web3_auth_ts_key_platform_interface.dart';

/// An implementation of [Web3AuthTsKeyPlatform] that uses method channels.
class MethodChannelWeb3AuthTsKey extends Web3AuthTsKeyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('web3_auth_ts_key');

  late InitializeParams params;

  @override
  Future<void> init(InitializeParams params,
      {InitProgressCallback? progressCallback}) async {
    this.params = params;
    await CustomAuth.init(
      network: params.network.toTorusNetworl(),
      browserRedirectUri:
          Uri.parse('https://scripts.toruswallet.io/redirect.html'),
      redirectUri: Uri.parse('torus://org.torusresearch.sample/redirect'),
      // enableOneKey: true,
    );
  }

  @override
  Future<String> getPostBoxKey() async {
    final credentials = await CustomAuth.getTorusKey(
      verifier: params.verifierName,
      verifierId: params.verifierId,
      idToken: params.idToken,
    );
    return credentials.privateKey;
  }

  @override
  Future<KeyDetails> initializeTsKey([String? privateKey]) async {
    final key = privateKey ?? await getPostBoxKey();
    final thresholdParams = ThresholdParams(
        privateKey: key,
        enableLogging: params.enableLogging,
        manualSync: params.manualSync,
        importShare: params.importShare,
        neverInitializeNewKey: params.neverInitializeNewKey,
        includeLocalMetadataTransitions:
            params.includeLocalMetadataTransitions);

    return KeyDetails.fromJson(
      asStringKeyedMap(
        await methodChannel.invokeMethod(
          'initialize',
          thresholdParams.toJson(),
        ),
      ),
    );
  }

  @override
  Future<ReconstructionDetails> reconstruct() async {
    return ReconstructionDetails.fromJson(
        asStringKeyedMap(await methodChannel.invokeMethod('reconstruct')));
  }

  @override
  Future<String> generateNewShare() async =>
      await methodChannel.invokeMethod('generateNewShare');

  @override
  Future<KeyDetails> deleteShare(String index) async {
    return KeyDetails.fromJson(asStringKeyedMap(
        await methodChannel.invokeMethod('generateNewShare', index)));
  }

  @override
  Future<void> inputShare(String share) async {
    await methodChannel.invokeMethod('inputShare', share);
  }

  @override
  Future<String> outputShare(String index) async =>
      await methodChannel.invokeMethod('outputShare', index);

  @override
  Future<List<String>> getSharesIndexes() async =>
      await methodChannel.invokeMethod('getSharesIndexes');

  @override
  Future<String> generateSecurityQuestion(
          String question, String answer) async =>
      await methodChannel
          .invokeMethod('generateSecurityQuestion', <String, dynamic>{
        'question': question,
        'answer': answer,
      });

  @override
  Future<void> changeSecurityQuestion(String question, String answer) async =>
      await methodChannel
          .invokeMethod('changeSecurityQuestion', <String, dynamic>{
        'question': question,
        'answer': answer,
      });

  @override
  Future<bool> inputSecurityQuestionShare(String answer) async =>
      await methodChannel.invokeMethod('inputSecurityQuestionShare', answer);

  @override
  Future<void> dispose() async {
    return;
  }

  Map<String, dynamic> asStringKeyedMap(Map<dynamic, dynamic> map) {
    //if (map == null) return null;
    if (map is Map<String, dynamic>) {
      return map;
    } else {
      return Map<String, dynamic>.from(map);
    }
  }
}
