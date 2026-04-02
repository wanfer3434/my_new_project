import 'dart:convert';
import 'dart:async';
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
  static const String baseUrl = 'https://javier.tail33d395.ts.net';

  final http.Client _client;

  RustApiChatService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  String _normalizeQuery(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sáéíóúñü-]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.parse(baseUrl).replace(
      path: path,
      queryParameters: queryParameters?.map(
            (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  Future<List<ProductResponse>> getProductMatch(String mensajeUsuario) async {
    final query = _normalizeQuery(mensajeUsuario);

    if (query.isEmpty) return [];

    try {
      final directResults = await _searchProducts(query);

      if (directResults.isNotEmpty) {
        return directResults;
      }

      final expandedQueries = _buildFallbackQueries(query);

      for (final fallbackQuery in expandedQueries) {
        final results = await _searchProducts(fallbackQuery);
        if (results.isNotEmpty) {
          return results;
        }
      }
    } catch (e) {
      print('❌ Excepción en getProductMatch: $e');
    }

    return [];
  }

  Future<List<ProductResponse>> _searchProducts(String query) async {
    try {
      final uri = _buildUri(
        '/buscar',
        {'q': query},
      );

      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      print('📥 GET $uri');
      print('📥 Status getProductMatch: ${response.statusCode}');
      print('📥 Body getProductMatch: ${response.body}');

      if (response.statusCode != 200) {
        print('❌ Error del servidor al obtener productos: ${response.statusCode}');
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        print('❌ La respuesta de /buscar no es una lista');
        return [];
      }

      return decoded
          .map<ProductResponse>((item) => ProductResponse.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ Excepción en _searchProducts("$query"): $e');
      return [];
    }
  }

  List<String> _buildFallbackQueries(String query) {
    final words = query
        .split(' ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final fallbacks = <String>{};

    if (words.length > 1) {
      fallbacks.add(words.join('%'));
    }

    final filteredWords = words.where((w) => w.length >= 3).toList();
    if (filteredWords.length > 1) {
      fallbacks.add(filteredWords.join(' '));
    }

    for (final word in filteredWords) {
      fallbacks.add(word);
    }

    return fallbacks.toList();
  }

  Future<String> getChatbotResponse(String mensajeUsuario) async {
    final message = mensajeUsuario.trim();

    if (message.isEmpty) {
      return '⚠️ Escribe un mensaje válido.';
    }

    try {
      final uri = _buildUri('/chatbot');

      final response = await _client
          .post(
        uri,
        headers: _jsonHeaders,
        body: jsonEncode({'mensaje': message}),
      )
          .timeout(const Duration(seconds: 12));

      print('📥 POST $uri');
      print('📥 Status chatbot: ${response.statusCode}');
      print('📥 Body chatbot: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return decoded['respuesta']?.toString() ??
              '⚠️ No se obtuvo respuesta del chatbot.';
        }

        return '⚠️ Respuesta inválida del chatbot.';
      }

      return '❌ Error del servidor: ${response.statusCode}';
    } on TimeoutException {
      return '⏳ La consulta tardó demasiado. Intenta nuevamente.';
    } catch (e) {
      return '❌ Error al obtener respuesta del chatbot: $e';
    }
  }

  static Future<List<User>> getUsers({required int nrUsers}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return List.generate(
      nrUsers,
          (index) => User(
        id: '$index',
        name: 'Usuario $index',
        profileImageUrl: 'https://i.pravatar.cc/150?img=$index',
      ),
    );
  }

  Future<List<RecomendacionStockResponse>> getRecomendacionStock(String? ref) async {
    final cleanedRef = ref?.trim();

    if (cleanedRef == null || cleanedRef.isEmpty) {
      print('❌ Error: ref es null o vacía');
      return [];
    }

    try {
      final uri = _buildUri('/recomendados', {'ref': cleanedRef});

      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      print('📥 GET $uri');
      print('📥 Status recomendacion-stock: ${response.statusCode}');
      print('📥 Body recomendacion-stock: ${response.body}');

      if (response.statusCode != 200) {
        print('❌ Error servidor recomendacion-stock: ${response.statusCode}');
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        print('❌ Error: La respuesta no es una lista');
        return [];
      }

      return decoded
          .map<RecomendacionStockResponse>(
            (e) => RecomendacionStockResponse.fromJson(e),
      )
          .toList();
    } on TimeoutException {
      print('❌ Timeout en getRecomendacionStock');
      return [];
    } catch (e) {
      print('❌ Excepción en getRecomendacionStock: $e');
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}