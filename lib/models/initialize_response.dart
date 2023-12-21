import 'package:web3_auth_ts_key/models/key_details.dart';

class InitializeResponse {
  final String privateKey;
  final KeyDetails keyDetails;

  InitializeResponse({
    required this.privateKey,
    required this.keyDetails,
  });
}
