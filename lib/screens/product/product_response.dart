// service/rust_api_chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductResponse {
  final String nombre;
  final double precio;
  final String color;
  final String? imagenUrl;

  ProductResponse({
    required this.nombre,
    required this.precio,
    required this.color,
    this.imagenUrl,
  });
}

class RustApiChatService {
  static const String baseUrl = 'https://e75b-186-154-129-90.ngrok-free.app';

  Future<ProductResponse?> getProductMatch(String mensajeUsuario) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/productos'));

      if (response.statusCode == 200) {
        final List productos = jsonDecode(response.body);

        final producto = productos.firstWhere(
          (producto) => producto['nombre']
              .toString()
              .toLowerCase()
              .contains(mensajeUsuario.toLowerCase()),
          orElse: () => null,
        );

        if (producto != null) {
          return ProductResponse(
            nombre: producto['nombre'],
            precio: producto['precio'].toDouble(),
            color: producto['color'],
            imagenUrl: producto['imagen'], // Asegúrate que tu API devuelve 'imagen'
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
