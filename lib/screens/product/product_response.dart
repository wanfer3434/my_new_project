class ProductResponse {
  final String? referencia;
  final double? precio;
  final String? imagen;
  final String? categoria;
  final int? cantidad;

  ProductResponse({
    this.referencia,
    this.precio,
    this.imagen,
    this.categoria,
    this.cantidad,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      referencia: json['referencia']?.toString(),
      precio: (json['precio'] as num?)?.toDouble(),
      imagen: json['imagen']?.toString(),
      categoria: json['categoria']?.toString(),
      cantidad: json['cantidad'] as int?,
    );
  }
}