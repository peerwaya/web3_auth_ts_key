import 'package:customauth_flutter/customauth_flutter.dart';

enum Network { mainnet, testnet, cyan, aqua, sapphire_devnet, sapphire_mainnet }

enum ChainNamespace { eip155, solana }

enum BuildEnv { production, staging, testing }

extension TorusNetworkExt on Network {
  TorusNetwork toTorusNetworl() => switch (this) {
        Network.mainnet => TorusNetwork.mainnet,
        Network.testnet => TorusNetwork.testnet,
        Network.aqua => TorusNetwork.aqua,
        Network.cyan => TorusNetwork.cyan,
        Network.sapphire_devnet => TorusNetwork.testnet,
        Network.sapphire_mainnet => TorusNetwork.mainnet,
      };
}
