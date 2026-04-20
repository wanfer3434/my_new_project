class PortfolioBalance {
  final String asset;
  final String free;
  final String locked;

  PortfolioBalance({
    required this.asset,
    required this.free,
    required this.locked,
  });

  factory PortfolioBalance.fromJson(Map<String, dynamic> json) {
    return PortfolioBalance(
      asset: json['asset']?.toString() ?? '',
      free: json['free']?.toString() ?? '0',
      locked: json['locked']?.toString() ?? '0',
    );
  }
}