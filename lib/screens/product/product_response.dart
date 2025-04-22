class ProductResponse {
  final String id;
  final String nombre;
  final String tipo;
  final String color;
  final double precio;
  final String fechaAgregado;
  final String? imagenUrl;

  ProductResponse({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.color,
    required this.precio,
    required this.fechaAgregado,
    this.imagenUrl,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      color: json['color'] ?? '',
      precio: (json['precio'] is int)
          ? (json['precio'] as int).toDouble()
          : (json['precio'] ?? 0.0).toDouble(),
      fechaAgregado: json['fecha_agregado'] ?? '',
      imagenUrl: json['imagen'] ?? 'https://example.com/default-image.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'color': color,
      'precio': precio,
      'fecha_agregado': fechaAgregado, // <- corregido aquí
      'imagen': imagenUrl, // <- corregido aquí
    };
  }
}
