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

      // Verifica si la respuesta fue exitosa
      if (response.statusCode == 200) {
        final List productos = jsonDecode(response.body);

        // Si se encuentran productos, los decodificamos y retornamos
        if (productos.isNotEmpty) {
          return productos.map<ProductResponse>((producto) {
            return ProductResponse.fromJson(producto);
          }).toList();
        } else {
          print('❌ No se encontraron productos');
        }
      } else {
        print('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getProductMatch: $e');
    }

    return []; // Devuelve una lista vacía en caso de error o si no se encuentran productos
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
      print('Referencia: ${product.referencia}');
      print('Categoría: ${product.categoria}');
      print('Precio: \$${product.precio}');
      print('Fecha de Venta: ${product.fechaVenta}');
      print('Imagen: ${product.imagen}');
      print('Cantidad: ${product.cantidad}');
      print('--------------------------------');
    }
  } else {
    print('❌ No se encontraron productos');
  }
}
