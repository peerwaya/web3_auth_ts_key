import 'package:web3_auth_ts_key/models/initialize_params.dart';
import 'package:web3_auth_ts_key/models/key_details.dart';
import 'package:web3_auth_ts_key/models/reconstruction_details.dart';

import 'web3_auth_ts_key_platform_interface.dart';

class Web3AuthTsKey {
  Future<KeyDetails> initialize(InitializeParams params) async {
    return Web3AuthTsKeyPlatform.instance.initialize(params);
  }

  Future<ReconstructionDetails> reconstruct() async {
    return Web3AuthTsKeyPlatform.instance.reconstruct();
  }

  Future<String> generateNewShare() async {
    return Web3AuthTsKeyPlatform.instance.generateNewShare();
  }

  Future<KeyDetails> deleteShare(String index) async {
    return Web3AuthTsKeyPlatform.instance.deleteShare(index);
  }

  Future<void> inputShare(String share) {
    return Web3AuthTsKeyPlatform.instance.inputShare(share);
  }

  Future<String> outputShare(String index) {
    return Web3AuthTsKeyPlatform.instance.outputShare(index);
  }

  Future<List<String>> getSharesIndexes() {
    return Web3AuthTsKeyPlatform.instance.getSharesIndexes();
  }

  Future<String> generateSecurityQuestion(String question, String answer) {
    return Web3AuthTsKeyPlatform.instance
        .generateSecurityQuestion(question, answer);
  }

  Future<bool> changeSecurityQuestion(String question, String answer) {
    return Web3AuthTsKeyPlatform.instance
        .changeSecurityQuestion(question, answer);
  }

  Future<bool> inputSecurityQuestionShare(String answer) {
    return Web3AuthTsKeyPlatform.instance.inputSecurityQuestionShare(answer);
  }
}
