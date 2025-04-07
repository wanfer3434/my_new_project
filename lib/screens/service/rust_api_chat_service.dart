import 'dart:convert';
import 'package:http/http.dart' as http;
import '../product/components/productR.dart';

class RustApiChatService {
  static const String baseUrl = 'https://f286-186-154-129-90.ngrok-free.app/productos';

  Future<ProductResponse?> getProductMatch(String mensajeUsuario) async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

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
            id: producto['id'].toString(),
            nombre: producto['nombre'],
            tipo: producto['tipo'],
            color: producto['color'],
            precio: double.tryParse(producto['precio'].toString()) ?? 0.0,
            fechaAgregado: producto['fecha_agregado'] ?? '',
            imagenUrl: producto['imagen'],
          );
        }
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
