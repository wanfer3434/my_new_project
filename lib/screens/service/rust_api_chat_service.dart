import 'dart:convert';
import 'package:http/http.dart' as http;
import '../product/components/productR.dart';

// Supón que esta clase User está definida en otro archivo o al final de este archivo
class User {
  final String id;
  final String name;
  final String profileImageUrl;

  User({required this.id, required this.name, required this.profileImageUrl});
}

class RustApiChatService {
  static const String baseUrl = 'https://javierfigueroa.tail33d395.ts.net';

  // 🟠 Este es tu método actual
  Future<ProductResponse?> getProductMatch(String mensajeUsuario) async {
    try {
      final query = mensajeUsuario.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      final response = await http.get(Uri.parse('$baseUrl/buscar?q=$query'));

      if (response.statusCode == 200) {
        final List productos = jsonDecode(response.body);

        if (productos.isNotEmpty) {
          final producto = productos.first;
          return ProductResponse(
            id: producto['id'].toString(),
            nombre: producto['nombre'],
            tipo: producto['tipo'],
            color: producto['color'],
            precio: double.tryParse(producto['precio'].toString()) ?? 0.0,
            fechaAgregado: producto['fecha_agregado'],
            imagenUrl: producto['imagen'],
          );
        }
      }

      return null;
    } catch (e) {
      print('Error en getProductMatch: $e');
      return null;
    }
  }


  // ✅ Este es el nuevo método que te faltaba
  static Future<List<User>> getUsers({required int nrUsers}) async {
    // Simula una espera como si fuera de un servidor real
    await Future.delayed(Duration(seconds: 1));

    // Retorna una lista ficticia de usuarios
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
