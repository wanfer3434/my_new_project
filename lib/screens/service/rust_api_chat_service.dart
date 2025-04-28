import 'dart:convert';
import 'package:http/http.dart' as http;
import '../product/product_response.dart';

class User {
  final String id;
  final String name;
  final String profileImageUrl;

  User({required this.id, required this.name, required this.profileImageUrl});
}

class RustApiChatService {
  // Dirección base de tu API Rust
  static const String baseUrl = 'https://javierfigueroa.tail33d395.ts.net';

  /// ✅ Buscar productos según el mensaje del usuario
  Future<List<ProductResponse>> getProductMatch(String mensajeUsuario) async {
    try {
      final query = mensajeUsuario.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
      final uri = Uri.parse('$baseUrl/buscar?q=$query');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List productos = jsonDecode(response.body);

        if (productos.isNotEmpty) {
          // Convertimos cada item del JSON a un ProductResponse
          return productos.map<ProductResponse>((producto) {
            return ProductResponse.fromJson(producto);
          }).toList();
        }
      }

      return []; // No se encontraron productos
    } catch (e) {
      print('Error en getProductMatch: $e');
      return [];
    }
  }

  /// Función de prueba para obtener usuarios ficticios
  static Future<List<User>> getUsers({required int nrUsers}) async {
    await Future.delayed(Duration(milliseconds: 500));

    return List.generate(
      nrUsers,
          (index) => User(
        id: '$index',
        name: 'Usuario $index',
        profileImageUrl: 'https://i.pravatar.cc/150?img=$index',
      ),
    );
  }
}

/// ✅ Ejemplo de uso manual
void main() async {
  final _chatService = RustApiChatService();
  final userMessage = 'fundas para celular';

  final List<ProductResponse> products = await _chatService.getProductMatch(userMessage);

  if (products.isNotEmpty) {
    for (var product in products) {
      print('Producto: ${product.nombre}');
      print('Precio: ${product.precio}');
      print('Color: ${product.color}');
      print('Tipo: ${product.tipo}');
      print('Fecha Agregado: ${product.fechaAgregado}');
      print('URLs Imagenes: ${product.imagenUrls.join(', ')}');
      print('--------------------------------');
    }
  } else {
    print('❌ No se encontraron productos');
  }
}
