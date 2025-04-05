import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = true;
  bool _hasError = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  final String baseUrl = 'https://abc123.ngrok.io'; // Cambia por tu URL de ngrok

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/productos'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _products = data.map((item) => Product.fromJson(item)).toList();
        _isLoading = false;
        _hasError = false;
      } else {
        throw Exception('Error en la API');
      }
    } catch (e) {
      _hasError = true;
      _isLoading = false;
    }
    notifyListeners();
  }
}
