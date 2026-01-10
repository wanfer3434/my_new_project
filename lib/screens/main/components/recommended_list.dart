import 'package:flutter/material.dart';
import 'package:my_new_project/app_properties.dart';
import 'package:my_new_project/models/product.dart';
import 'package:my_new_project/screens/product/components/product_card.dart';

class RecommendedList extends StatelessWidget {
  final String category;
  final ScrollController? controller; // Controller opcional

  const RecommendedList({super.key, required this.category, this.controller});

  List<Product> get allProducts => [
    Product(
      id: 'promo_01',
      imageUrls: [
        'https://i.imgur.com/4mejGU4.jpg',
        'https://i.imgur.com/3Lk2fcw.jpg'
      ],
      name: 'Forro con cadena',
      description: 'Diseño para Dama',
      price: 30000,
      category: 'Edición Limitada',
    ),
    Product(
      id: 'promo_02',
      imageUrls: [
        'https://i.imgur.com/4mejGU4.jpg',
        'https://i.imgur.com/3Lk2fcw.jpg'
      ],
      name: 'Forro con cadena',
      description: 'Diseño para Dama',
      price: 30000,
      category: 'Edición Limitada',
    ),
    Product(
      id: 'vidrios',
      imageUrls: [
        'https://i.imgur.com/G4z0HpV.png',
        'https://i.imgur.com/1nt75XM.jpeg'
      ],
      name: 'Vidrios para Pantalla',
      description: 'A70',
      price: 1000,
      category: 'Protectores Celular',
    ),
    Product(
      id: 'vidrios-linea',
      imageUrls: [
        'https://i.imgur.com/GKAMvDV.jpeg',
        'https://i.imgur.com/FJPEqJ2.jpeg'
      ],
      name: 'Vidrios para Pantalla',
      description: 'A70',
      price: 1000,
      category: 'Protectores Celular',
    ),
    Product(
      id: 'vidrios-curvo-antiespia',
      imageUrls: [
        'https://i.imgur.com/1nt75XM.jpeg',
        'https://i.imgur.com/BRFr1f5.jpeg'
      ],
      name: 'Vidrios para Pantalla',
      description: 'A70',
      price: 1000,
      category: 'Protectores Celular',
    ),
    Product(
      id: 'cam_01',
      imageUrls: [
        'https://i.imgur.com/GB1hy1B.jpg',
        'https://i.imgur.com/MtMle6w.jpg'
      ],
      name: 'Cámara Vintage',
      description: 'Digital Camera',
      price: 300000,
      category: 'Camaras',
    ),
    Product(
      id: 'cam_02',
      imageUrls: [
        'https://i.imgur.com/EKmFTAk.jpg',
        'https://i.imgur.com/U9KP4c5.jpg',
      ],
      name: 'Cámara Vintage',
      description: 'Colección',
      price: 320000,
      category: 'Camaras',
    ),
    Product(
      id: 'cam_03',
      imageUrls: [
        'https://i.imgur.com/IkyYPoB.jpg',
        'https://i.imgur.com/xdA1ci9.jpg',
      ],
      name: 'Cámara Vintage',
      description: 'Clásica',
      price: 350000,
      category: 'Camaras',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = allProducts
        .where((p) =>
        p.category.toLowerCase().contains(category.toLowerCase()))
        .toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No hay productos en esta categoría',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return CustomScrollView(
      controller: controller,
      slivers: [
        // 🟡 Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 4,
                  height: 24,
                  color: mediumYellow,
                ),
                const Text(
                  'Recomendado',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🟡 Grid de productos
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final product = filteredProducts[index];
                return ProductCard(
                  product: product,
                  height: 210,
                  width: MediaQuery.of(context).size.width,
                );
              },
              childCount: filteredProducts.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
          ),
        ),

        // 🟡 Espacio inferior para no tapar con el BottomNavigationBar
        SliverToBoxAdapter(
          child: SizedBox(height: kBottomNavigationBarHeight),
        ),
      ],
    );
  }
}
