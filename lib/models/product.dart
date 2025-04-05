import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrls;
  final double price;
  final double? averageRating;
  final int? ratingCount;
  final String category; // Agregamos la propiedad 'category'

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.price,
    this.averageRating,
    this.ratingCount,
    required this.category, // Asegurar que sea requerida o dar un valor por defecto
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? 'Sin descripción',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'] as int?,
      category: json['category'] ?? 'Uncategorized',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
      'price': price,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'category': category, // Asegurar que se incluya en la conversión
    };
  }
}
