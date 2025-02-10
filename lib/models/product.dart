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

  factory Product.fromFirestore(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      imageUrls: List<String>.from(data['imageUrls']),
      price: (data['price'] as num).toDouble(),
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      ratingCount: data['ratingCount'] as int?,
      category: data['category'] ?? 'Uncategorized', // Asignamos un valor por defecto si falta
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
