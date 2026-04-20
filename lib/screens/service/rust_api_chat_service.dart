import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../../models/bot_order.dart';
import '../../models/portfolio_balance.dart';
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

  // ⚠️ CAMBIA ESTE TOKEN (y no lo subas a GitHub)
  static const String adminToken = 'c1f93a332e4b8cbe5441834899042082071f2a0069bf3126f681b9c45307e825';

  final http.Client _client;

  RustApiChatService({http.Client? client})
      : _client = client ?? http.Client();

  // =========================
  // HEADERS
  // =========================

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $adminToken',
  };

  // =========================
  // HELPERS
  // =========================

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

  // =========================
  // PRODUCTOS
  // =========================

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
      final uri = _buildUri('/buscar', {'q': query});

      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) return [];

      return decoded
          .map<ProductResponse>((item) => ProductResponse.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<String> _buildFallbackQueries(String query) {
    final words = query.split(' ');

    final fallbacks = <String>{};

    if (words.length > 1) {
      fallbacks.add(words.join('%'));
    }

    for (final word in words) {
      if (word.length >= 3) {
        fallbacks.add(word);
      }
    }

    return fallbacks.toList();
  }

  // =========================
  // CHATBOT
  // =========================

  Future<String> getChatbotResponse(String mensajeUsuario) async {
    final message = mensajeUsuario.trim();

    if (message.isEmpty) {
      return '⚠️ Escribe un mensaje válido.';
    }

    try {
      final uri = _buildUri('/chatbot');

      final response = await _client.post(
        uri,
        headers: _jsonHeaders,
        body: jsonEncode({'mensaje': message}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        return decoded['respuesta']?.toString() ??
            '⚠️ Sin respuesta del chatbot.';
      }

      return '❌ Error servidor: ${response.statusCode}';
    } catch (e) {
      return '❌ Error chatbot: $e';
    }
  }

  // =========================
  // 🔥 CRYPTO / BINANCE
  // =========================

  /// PORTFOLIO
  Future<List<PortfolioBalance>> getPortfolio() async {
    try {
      final uri = _buildUri('/api/portfolio');

      final response = await _client.get(uri, headers: _authHeaders);

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final decoded = jsonDecode(response.body);
      return decoded['balances'] ?? [];
    } catch (e) {
      print('❌ Error getPortfolio: $e');
      return [];
    }
  }

  /// ORDERS
  Future<List<BotOrder>> getOrders() async {
    try {
      final uri = _buildUri('/api/orders');

      final response = await _client.get(uri, headers: _authHeaders);

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Error getOrders: $e');
      return [];
    }
  }

  /// BOT RUN ONCE
  Future<Map<String, dynamic>?> runBotOnce({
    String symbol = 'BTCUSDT',
    double amount = 10,
  }) async {
    try {
      final uri = _buildUri('/api/bot/run-once');

      final response = await _client.post(
        uri,
        headers: _authHeaders,
        body: jsonEncode({
          'symbol': symbol,
          'quote_amount_usdt': amount,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Error runBotOnce: $e');
      return null;
    }
  }

  // =========================
  // STOCK RECOMENDADO
  // =========================

  Future<List<RecomendacionStockResponse>> getRecomendacionStock(
      String? ref) async {
    if (ref == null || ref.trim().isEmpty) return [];

    try {
      final uri = _buildUri('/recomendados', {'ref': ref});

      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) return [];

      return decoded
          .map<RecomendacionStockResponse>(
              (e) => RecomendacionStockResponse.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // USERS MOCK
  // =========================

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

  void dispose() {
    _client.close();
  }
}