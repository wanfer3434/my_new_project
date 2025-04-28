class ProductResponse {
  final String nombre;
  final String tipo;
  final String color;
  final double precio;
  final DateTime fechaAgregado;  // Cambié a DateTime
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
    // Si 'imagenUrls' es un string con comas, separarlas y convertirlas en una lista.
    List<String> imagenUrlsList = [];
    if (json['imagenUrls'] != null) {
      if (json['imagenUrls'] is String) {
        imagenUrlsList = json['imagenUrls'].split(',').map((e) => e.trim()).toList();
      } else if (json['imagenUrls'] is List) {
        imagenUrlsList = List<String>.from(json['imagenUrls']);
      }
    }

    return ProductResponse(
      nombre: json['nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      color: json['color'] ?? '',
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      fechaAgregado: json['fechaAgregado'] != null ? DateTime.parse(json['fechaAgregado']) : DateTime.now(),
      imagenUrls: imagenUrlsList,
    );
  }
}
