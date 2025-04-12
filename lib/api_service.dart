import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_int2/screens/product/components/productR.dart';
import 'package:ecommerce_int2/models/user.dart'; // asegúrate de tener este archivo

class RustApiChatService {
  final String baseUrl = 'http://192.168.0.21:3000'; // Tu IP local

  /// Buscar producto por nombre
  Future<ProductResponse?> getProductMatch(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/productos'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        for (var item in data) {
          final product = ProductResponse.fromJson(item);
          if (product.nombre.toLowerCase().contains(query.toLowerCase())) {
            return product;
          }
        }
      }
    } catch (e) {
      print('Error buscando producto: $e');
    }
    return null;
  }

  /// Obtener usuarios (dummy o desde API real)
  static Future<List<User>> getUsers({int nrUsers = 5}) async {
    try {
      final response = await http.get(Uri.parse('https://randomuser.me/api/?results=$nrUsers'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar usuarios');
      }
    } catch (e) {
      print('Error en getUsers: $e');
      return [];
    }
  }
}
