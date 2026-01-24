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
      producto: json['referencia'] ?? 'Sin nombre', // antes json['producto']
      stock: json['cantidad'] ?? 0,                 // antes json['stock']
      vendidos7Dias: 0,                            // si no viene del servidor, puedes inicializar 0
    );
  }
}
