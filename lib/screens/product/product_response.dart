class ProductResponse {
  final String referencia;
  final String categoria;
  final double precio;
  final DateTime? fechaVenta;
  final String? imagen;
  final int cantidad;

  ProductResponse({
    required this.referencia,
    required this.categoria,
    required this.precio,
    required this.fechaVenta,
    required this.imagen,
    required this.cantidad,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      referencia: json['referencia'] ?? '',
      categoria: json['categoria'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      fechaVenta: json['fecha_venta'] is String
          ? DateTime.tryParse(json['fecha_venta']) ?? DateTime(1970, 1, 1) // Valor por defecto si no se puede parsear
          : null,
      imagen: json['imagen'] ?? 'https://via.placeholder.com/150', // Imagen predeterminada
      cantidad: json['cantidad'] ?? 0,
    );
  }
}
