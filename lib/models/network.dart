class Web3AuthNetwork {
  final Network network;

  Web3AuthNetwork({required this.network});

  Map<String, dynamic> toJson() {
    return {
      'network': network.name,
    };
  }
}

enum Network { mainnet, testnet, cyan, aqua, sapphire_devnet, sapphire_mainnet }
