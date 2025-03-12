import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/product/product_page.dart';

class RecommendedList extends StatefulWidget {
  final String category;

  RecommendedList({required this.category});

  @override
  _RecommendedListState createState() => _RecommendedListState();
}

class _RecommendedListState extends State<RecommendedList> {
  final List<Product> allProducts = [
    Product(
      id: '1',
      imageUrls: ['https://i.imgur.com/4mejGU4.jpg', 'https://i.imgur.com/3Lk2fcw.jpg'],
      name: 'Forro con cadena',
      description: 'Diseño para Dama',
      price: 30000,
      category: 'Plantas & Diagnóstico',
    ),
    Product(
      id: '2',
      imageUrls: ['https://i.imgur.com/G4z0HpV.png', 'https://i.imgur.com/Xf2TEUR.png'],
      name: 'Vidrios para Pantalla',
      description: 'A70',
      price: 1000,
      category: 'Celulares',
    ),
    Product(
      id: '3',
      imageUrls: ['https://i.imgur.com/5zqRhBS.png'],
      name: 'Botones',
      description: 'Astronautas',
      price: 2000,
      category: 'Audífonos',
    ),
    Product(
      id: '4',
      imageUrls: [
        'https://imgur.com/nRnC2Pr', 'https://imgur.com/LApJ975',
        'https://imgur.com/8uWbc0e', 'https://imgur.com/Nxw35JW',
        'https://imgur.com/01wfOd9', 'https://imgur.com/AHzgrev'
      ],
      name: 'Cámaras Videograbables',
      description: 'Digital Camera',
      price: 30000,
      category: 'Camaras',
    ),
    Product(
      id: '5',
      imageUrls: ['https://i.imgur.com/zgyf3ow.jpg', 'https://i.imgur.com/sOcdUi7.jpg'],
      name: 'Vidrios para Pantallas curvos',
      description: 'Digital Camera',
      price: 30000,
      category: 'Celulares',
    ),
  ];

  Map<String, double> _currentRatings = {};
  Map<String, int> _ratingCounts = {};
  late List<int> _currentImageIndices;
  Timer? _imageChangeTimer;

  @override
  void initState() {
    super.initState();

    _currentImageIndices = List.generate(allProducts.length, (_) => 0);
    for (var product in allProducts) {
      _currentRatings[product.id] = 4.5;
      _ratingCounts[product.id] = 200;
    }

    _imageChangeTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          for (int i = 0; i < allProducts.length; i++) {
            if (allProducts[i].imageUrls.isNotEmpty) {
              _currentImageIndices[i] =
                  (_currentImageIndices[i] + 1) % allProducts[i].imageUrls.length;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _imageChangeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts =
    allProducts.where((p) => p.category == widget.category).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 16.0, right: 8.0),
                    width: 4,
                    color: mediumYellow,
                  ),
                  Text(
                    'Recomendado',
                    style: TextStyle(
                      color: darkGrey,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            filteredProducts.isEmpty
                ? Center(
              child: Text(
                'No hay productos en esta categoría',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
                : SizedBox(
              height: constraints.maxHeight - 50, // Ajusta la altura para evitar errores
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: MasonryGridView.count(
                  physics: BouncingScrollPhysics(),
                  crossAxisCount: 2,
                  itemCount: filteredProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = filteredProducts[index];
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductPage(product: product),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Hero(
                            tag: product.imageUrls[0],
                            child: Image.network(
                              product.imageUrls[_currentImageIndices[index]],
                              fit: BoxFit.cover,
                              height: 190,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '\$${product.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Colors.black87,
                                  ),
                                ),
                                RatingBar.builder(
                                  initialRating: _currentRatings[product.id]!,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      _currentRatings[product.id] = rating;
                                      _ratingCounts[product.id] =
                                      (_ratingCounts[product.id]! + 1);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
