class ProductResponse {
  final String nombre;
  final String tipo;
  final String color;
  final double precio;
  final DateTime fechaAgregado;
  final List<String> imagenUrls;

  ProductResponse({
    required this.nombre,
    required this.tipo,
    required this.color,
    required this.precio,
    required this.fechaAgregado,
    required this.imagenUrls,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    // Adaptar para soportar ambos campos
    final imagen = json['imagen'];
    List<String> imagenes = [];

    if (imagen != null) {
      if (imagen is String) {
        imagenes = [imagen];
      } else if (imagen is List) {
        imagenes = List<String>.from(imagen);
      }
    }

    return ProductResponse(
      nombre: json['nombre'],
      tipo: json['tipo'],
      color: json['color'],
      precio: (json['precio'] as num).toDouble(),
      fechaAgregado: DateTime.parse(json['fecha_agregado']),
      imagenUrls: imagenes,
    );
  }
}
