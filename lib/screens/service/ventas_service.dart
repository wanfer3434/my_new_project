import 'dart:convert';
import 'package:http/http.dart' as http;

class VentasService {
  static const String baseUrl = 'https://javier-1.tail33d395.ts.net';

  static Future<bool> registrarVenta({
    required String referencia,
    required double precio,
    required int cantidad,
    String? canal,
    String? clienteNombre,
    String? clienteTelefono,
  }) async {
    final url = Uri.parse('$baseUrl/venta');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'producto_referencia': referencia,
        'precio': precio,
        'cantidad': cantidad,
        'canal': canal ?? 'App Flutter',
        'cliente_nombre': clienteNombre,
        'cliente_telefono': clienteTelefono,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> obtenerVentasHoy() async {
    final url = Uri.parse('$baseUrl/ventas-hoy');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Error cargando ventas de hoy');
  }
}