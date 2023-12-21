import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:web3_auth_ts_key/models/initialize_params.dart';
import 'package:web3_auth_ts_key/models/key_details.dart';
import 'package:web3_auth_ts_key/models/reconstruction_details.dart';
import 'package:web3_auth_ts_key/native/browser.dart';

import 'web3_auth_ts_key_method_channel.dart';

typedef InitProgressCallback = Function(int progress);

abstract class Web3AuthTsKeyPlatform extends PlatformInterface {
  /// Constructs a Web3AuthTsKeyPlatform.
  Web3AuthTsKeyPlatform() : super(token: _token);

  static final Object _token = Object();

  static Web3AuthTsKeyPlatform _instance = BrowserNative();
  //static Web3AuthTsKeyPlatform _instance = MethodChannelWeb3AuthTsKey();

  /// The default instance of [Web3AuthTsKeyPlatform] to use.
  ///
  /// Defaults to [MethodChannelWeb3AuthTsKey].
  static Web3AuthTsKeyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Web3AuthTsKeyPlatform] when
  /// they register themselves.
  static set instance(Web3AuthTsKeyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(InitializeParams params,
      {InitProgressCallback? progressCallback}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<String> getPostBoxKey() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<KeyDetails> initializeTsKey([String? privateKey]) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<ReconstructionDetails> reconstruct() {
    throw UnimplementedError('reconstruct() has not been implemented.');
  }

  Future<String> generateNewShare() {
    throw UnimplementedError('generateNewShare() has not been implemented.');
  }

  Future<KeyDetails> deleteShare(String index) {
    throw UnimplementedError('reconstruct() has not been implemented.');
  }

  Future<void> inputShare(String share) {
    throw UnimplementedError('inputShare() has not been implemented.');
  }

  Future<String> outputShare(String index) {
    throw UnimplementedError('inputShare() has not been implemented.');
  }

  Future<List<String>> getSharesIndexes() {
    throw UnimplementedError('getSharesIndexes() has not been implemented.');
  }

  Future<String> generateSecurityQuestion(String question, String answer) {
    throw UnimplementedError(
        'generateSecurityQuestion() has not been implemented.');
  }

  Future<bool> changeSecurityQuestion(String question, String answer) {
    throw UnimplementedError(
        'changeSecurityQuestion() has not been implemented.');
  }

  Future<bool> inputSecurityQuestionShare(String answer) {
    throw UnimplementedError(
        'changeSecurityQuestion() has not been implemented.');
  }

  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
