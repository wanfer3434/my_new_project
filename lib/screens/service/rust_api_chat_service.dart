import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/recomendacion_stock_response.dart';
import '../product/product_response.dart';

class User {
  final String id;
  final String name;
  final String profileImageUrl;

  User({
    required this.id,
    required this.name,
    required this.profileImageUrl,
  });
}

class RustApiChatService {
  // Dirección base de tu API en Rust


  static const String baseUrl = 'https://javier.tail33d395.ts.net';


  /// ✅ Buscar productos según el mensaje del usuario
  Future<List<ProductResponse>> getProductMatch(String mensajeUsuario) async {
    try {
      final query =
          mensajeUsuario.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
      final uri = Uri.parse('$baseUrl/buscar?q=$query');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> productos = jsonDecode(response.body);

        if (productos.isNotEmpty) {
          return productos.map<ProductResponse>((producto) {
            return ProductResponse.fromJson(producto);
          }).toList();
        } else {
          print('❌ No se encontraron productos que coincidan.');
        }
      } else {
        print(
            '❌ Error del servidor al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Excepción en getProductMatch: $e');
    }

    return [];
  }

  /// ✅ Obtener respuesta del chatbot desde la API en Rust
  
Future<String> getChatbotResponse(String mensajeUsuario) async {
  try {
    final uri = Uri.parse('$baseUrl/chatbot');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mensaje': mensajeUsuario}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData['respuesta'] ?? '⚠️ No se obtuvo respuesta del chatbot.';
    } else {
      return '❌ Error del servidor: ${response.statusCode}';
    }
  } catch (e) {
    return '❌ Error al obtener respuesta del chatbot: $e';
  }
}


  /// ✅ Obtener lista ficticia de usuarios (modo demo)
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

  /// ✅ Obtener recomendaciones de stock desde la API
  Future<List<RecomendacionStockResponse>> getRecomendacionStock(String? ref) async {
    if (ref == null || ref.isEmpty) {
      print('❌ Error: ref es null o vacía');
      return [];
    }

    try {
      final uri = Uri.parse('$baseUrl/recomendados?ref=$ref');
      final response = await http.get(uri);

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded.map((e) => RecomendacionStockResponse.fromJson(e)).toList();
        } else {
          print('❌ Error: La respuesta no es una lista');
          return [];
        }
      } else {
        print('❌ Error servidor recomendacion-stock: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Excepción en getRecomendacionStock: $e');
    }

    return [];
  }

}

