class ChainConfig {
  final String chainNamespace;
  final String chainId;
  final String rpcTarget;
  final String displayName;
  final String blockExplorer;
  final String ticker;
  final String tickerName;

  ChainConfig({
    required this.chainNamespace,
    required this.chainId,
    required this.rpcTarget,
    required this.displayName,
    required this.blockExplorer,
    required this.ticker,
    required this.tickerName,
  });
}
