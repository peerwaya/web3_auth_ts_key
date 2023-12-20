import 'package:web3_auth_ts_key/models/enums.dart';

class CustomAuthParams {
  final Network network;
  final String web3AuthClientId;
  final String baseUrl;
  final bool enableLogging;

  CustomAuthParams({
    required this.network,
    required this.web3AuthClientId,
    this.baseUrl = "",
    this.enableLogging = false,
  });
}
