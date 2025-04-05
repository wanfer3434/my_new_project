import 'dart:convert';
import 'package:http/http.dart' as http;

class RustApiChatService {
  static const String baseUrl = 'https://e75b-186-154-129-90.ngrok-free.app';

  Future<String> getBotResponse(String mensajeUsuario) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/productos'));

      if (response.statusCode == 200) {
        final List productos = jsonDecode(response.body);

        final productoEncontrado = productos.firstWhere(
          (producto) => producto['nombre']
              .toString()
              .toLowerCase()
              .contains(mensajeUsuario.toLowerCase()),
          orElse: () => null,
        );

        if (productoEncontrado != null) {
          return 'Tenemos "${productoEncontrado['nombre']}" en color ${productoEncontrado['color']} por \$${productoEncontrado['precio']}.';
        } else {
          return 'No encontré un producto con esa referencia.';
        }
      } else {
        return 'Error al conectar con la API.';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
