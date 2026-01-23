class RecomendacionStockResponse {
  final String producto;
  final int stock;
  final int vendidos7Dias;

  RecomendacionStockResponse({
    required this.producto,
    required this.stock,
    required this.vendidos7Dias,
  });

  factory RecomendacionStockResponse.fromJson(Map<String, dynamic> json) {
    return RecomendacionStockResponse(
      producto: json['producto'],
      stock: json['stock'],
      vendidos7Dias: json['vendidos_7_dias'],
    );
  }
}
