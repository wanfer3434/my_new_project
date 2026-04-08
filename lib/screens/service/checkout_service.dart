import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CheckoutService {
  static const String baseUrl = 'https://javier.tail33d395.ts.net';

  Future<String?> createCheckout({
    required List<Map<String, dynamic>> cartItems,
    required double total,
    String paymentMethod = 'nequi',
  }) async {
    final uri = Uri.parse('$baseUrl/checkout/create');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'items': cartItems,
        'total': total,
        'currency': 'COP',
        'payment_method': paymentMethod,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo crear el checkout. Código: ${response.statusCode} - ${response.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final String? checkoutUrl = data['checkout_url'] as String?;

    if (checkoutUrl == null || checkoutUrl.isEmpty) {
      throw Exception('La respuesta no contiene checkout_url válido');
    }

    final checkoutUri = Uri.parse(checkoutUrl);

    final launched = await launchUrl(
      checkoutUri,
      mode: LaunchMode.platformDefault,
    );

    if (!launched) {
      throw Exception('No se pudo abrir la URL de pago');
    }

    return checkoutUrl;
  }
}