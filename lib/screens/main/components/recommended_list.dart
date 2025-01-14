import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/product/product_page.dart';

class RecommendedList extends StatefulWidget {
  @override
  _RecommendedListState createState() => _RecommendedListState();
}

class _RecommendedListState extends State<RecommendedList> {
  final List<Product> products = [
    Product(
        id: '1',
        imageUrls: ['https://i.imgur.com/4mejGU4.jpg', 'https://i.imgur.com/3Lk2fcw.jpg'],
        name: 'Forro con cadena',
        description: 'Diseño para Dama',
        price: 30000),
    Product(
        id: '2',
        imageUrls: ['https://i.imgur.com/G4z0HpV.png', 'https://i.imgur.com/Xf2TEUR.png'],
        name: 'Vidrios para Pantalla',
        description: 'A70',
        price: 1000),
    Product(
        id: '3',
        imageUrls: ['https://i.imgur.com/5zqRhBS.png'],
        name: 'Botones',
        description: 'Astronautas',
        price: 2000),
    // Agrega más productos aquí...
  ];

  Map<String, double> _currentRatings = {};
  Map<String, int> _ratingCounts = {};
  late List<int> _currentImageIndices;
  Timer? _imageChangeTimer;

  @override
  void initState() {
    super.initState();

    // Inicializar índices de imágenes y calificaciones
    _currentImageIndices = List.generate(products.length, (_) => 0);
    products.forEach((product) {
      _currentRatings[product.id] = 4.5;
      _ratingCounts[product.id] = 200;
    });

    // Configurar el temporizador para cambiar las imágenes automáticamente
    _imageChangeTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        for (int i = 0; i < products.length; i++) {
          _currentImageIndices[i] = (_currentImageIndices[i] + 1) % products[i].imageUrls.length;
        }
      });
    });
  }

  @override
  void dispose() {
    _imageChangeTimer?.cancel(); // Cancelar el temporizador al salir
    super.dispose();
  }

  void _saveRating(String productId, double rating) {
    setState(() {
      _currentRatings[productId] = rating;
      _ratingCounts[productId] = _ratingCounts[productId]! + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  IntrinsicHeight(
                    child: Container(
                      margin: const EdgeInsets.only(left: 16.0, right: 8.0),
                      width: 4,
                      color: mediumYellow,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Recomendado',
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: MasonryGridView.count(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = products[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductPage(product: product),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.grey.withOpacity(0.3),
                                Colors.grey.withOpacity(0.7),
                              ],
                              center: Alignment(0, 0),
                              radius: 0.6,
                              focal: Alignment(0, 0),
                              focalRadius: 0.1,
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
                                  height: constraints.maxWidth < 600 ? 190 : 300,
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
                                    SizedBox(height: 0.7),
                                    Text(
                                      product.description,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 0.7),
                                    Text(
                                      '\$${product.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 0.7),
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
                                        _saveRating(product.id, rating);
                                      },
                                    ),
                                    SizedBox(height: 0.5),
                                    Text(
                                      'Promedio: ${_currentRatings[product.id]} (${_ratingCounts[product.id]} opiniones)',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
