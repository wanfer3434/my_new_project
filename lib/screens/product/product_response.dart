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
  List<String> imagenUrlsList = [];

  final imagenRaw = json['imagen'] ?? json['imagenUrls']; // Soporta ambos

  if (imagenRaw != null) {
    if (imagenRaw is String) {
      try {
        // Intenta decodificar si es un string tipo JSON
        final decoded = jsonDecode(imagenRaw);
        if (decoded is List) {
          imagenUrlsList = List<String>.from(decoded);
        } else {
          imagenUrlsList = imagenRaw.split(',').map((e) => e.trim()).toList();
        }
      } catch (_) {
        imagenUrlsList = imagenRaw.split(',').map((e) => e.trim()).toList();
      }
    } else if (imagenRaw is List) {
      imagenUrlsList = List<String>.from(imagenRaw);
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
 
