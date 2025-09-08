import 'package:my_new_project/app_properties.dart';
import 'package:my_new_project/models/product.dart';
import 'package:my_new_project/screens/product/components/product_card.dart';
import 'package:flutter/material.dart';

class MoreProducts extends StatelessWidget {
  final List<Product> products;
  final String category; // Categoría de los productos

  MoreProducts({Key? key, required this.category, List<Product>? products})
      : products = products ??
      [
        Product(
          id: 'headset_l325',
          imageUrls: ['assets/headphones_2.png'],
          name: 'Skullcandy Headset L325',
          description: 'Auriculares de alta calidad con sonido envolvente.',
          price: 102.99,
          category: 'Auriculares',
        ),
        Product(
          id: 'headset_x25',
          imageUrls: ['assets/headphones_3.png'],
          name: 'Skullcandy Headset X25',
          description: 'Comodidad y calidad de sonido a un precio accesible.',
          price: 55.99,
          category: 'Auriculares',
        ),
        Product(
          id: 'blackzy_pro_m003',
          imageUrls: ['assets/headphones.png'],
          name: 'Blackzy PRO Headphones M003',
          description: 'Cancelación de ruido avanzada y diseño premium.',
          price: 152.99,
          category: 'Auriculares',
        ),
      ],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtrar productos por categoría
    List<Product> filteredProducts =
    products.where((product) => product.category == category).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 24.0, bottom: 8.0),
          child: Text(
            'More $category',
            style: TextStyle(color: Colors.white, shadows: shadow),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          height: 250,
          child: filteredProducts.isEmpty
              ? Center(
            child: Text(
              'No hay productos en esta categoría.',
              style: TextStyle(color: Colors.white70),
            ),
          )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 24.0 : 8.0,
                  right: index == filteredProducts.length - 1 ? 24.0 : 8.0,
                ),
                child: ProductCard(
                  product: filteredProducts[index],
                  height: 150.0,
                  width: 120.0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
