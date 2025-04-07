// service/rust_api_chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductResponse {
  final String id;
  final String nombre;
  final String tipo;
  final String color;
  final double precio;
  final String fechaAgregado;
  final String? imagenUrl;

  ProductResponse({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.color,
    required this.precio,
    required this.fechaAgregado,
    this.imagenUrl,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      color: json['color'] ?? '',
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      fechaAgregado: json['fechaAgregado'] ?? '',
      imagenUrl: json['imagen'], // <-- O puede ser json['imagenUrl'] si así viene
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'color': color,
      'precio': precio,
      'fechaAgregado': fechaAgregado,
      'imagenUrl': imagenUrl,
    };
  }
}

