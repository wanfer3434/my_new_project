class BotOrder {
  final int id;
  final String symbol;
  final String side;
  final double quoteSpent;
  final double? baseQty;
  final double? price;
  final String status;
  final String? exchangeOrderId;
  final String? rawResponse;
  final String createdAt;

  BotOrder({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quoteSpent,
    this.baseQty,
    this.price,
    required this.status,
    this.exchangeOrderId,
    this.rawResponse,
    required this.createdAt,
  });

  factory BotOrder.fromJson(Map<String, dynamic> json) {
    return BotOrder(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      symbol: json['symbol']?.toString() ?? '',
      side: json['side']?.toString() ?? '',
      quoteSpent: (json['quote_spent'] as num?)?.toDouble() ?? 0.0,
      baseQty: (json['base_qty'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? '',
      exchangeOrderId: json['exchange_order_id']?.toString(),
      rawResponse: json['raw_response']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}