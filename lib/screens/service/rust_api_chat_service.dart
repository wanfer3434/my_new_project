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
  static const String baseUrl = 'https://javierfigueroa.tail33d395.ts.net';

  /// ✅ Buscar productos por nombre (retorna una lista)
  Future<List<ProductResponse>> getProductMatch(String mensajeUsuario) async {
    try {
      final query = mensajeUsuario.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      final response = await http.get(Uri.parse('$baseUrl/buscar?q=$query'));

      if (response.statusCode == 200) {
        final List productos = jsonDecode(response.body);

        if (productos.isNotEmpty) {
          // Mapeamos la respuesta a una lista de ProductResponse
          return productos.map<ProductResponse>((producto) {
            return ProductResponse.fromJson(producto);
          }).toList();
        }
      }

      return [];
    } catch (e) {
      print('Error en getProductMatch: $e');
      return [];
    }
  }

  /// Usuarios ficticios (puedes adaptar a tu API real)
  static Future<List<User>> getUsers({required int nrUsers}) async {
    await Future.delayed(Duration(seconds: 1));

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

void main() async {
  // Suponiendo que se hace la llamada a la API para obtener los productos
  final _chatService = RustApiChatService();
  final userMessage = 'fundas para celular';

  // Obtener la lista de productos
  final List<ProductResponse> products = await _chatService.getProductMatch(userMessage);

  // Asegurándonos de que hay productos antes de acceder a ellos
  if (products.isNotEmpty) {
    // Imprimir los productos
    for (var product in products) {
      // Accediendo a las propiedades de cada objeto ProductResponse
      print('Producto: ${product.nombre}');  // Accedemos a 'nombre' de cada producto
      print('Precio: ${product.precio}');
      print('Color: ${product.color}');
      print('Tipo: ${product.tipo}');
      print('Fecha Agregado: ${product.fechaAgregado}');
      print('URL Imagen: ${product.imagenUrl}');
    }
  } else {
    print('No se encontraron productos');
  }
}
