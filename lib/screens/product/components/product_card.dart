import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';

import 'package:my_new_project/models/product.dart';
import 'package:my_new_project/providers/cart_provider.dart';
import 'package:my_new_project/screens/product/product_page.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final double height;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    required this.height,
    required this.width,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late final PageController _pageController;
  Timer? _autoSwipeTimer;
  int _currentPage = 0;

  double _currentRating = 0;
  double _averageRating = 4.5;
  int _ratingCount = 20;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.product.imageUrls.length > 1) {
      _autoSwipeTimer = Timer.periodic(
        const Duration(seconds: 3),
            (_) {
          if (!mounted) return;

          _currentPage = (_currentPage + 1) % widget.product.imageUrls.length;

          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _saveRating(double rating) {
    final total = _averageRating * _ratingCount;
    setState(() {
      _ratingCount++;
      _averageRating = (total + rating) / _ratingCount;
    });
  }

  int _getProductId() {
    return widget.product.name.hashCode;
  }

  String _getMainImage() {
    if (widget.product.imageUrls.isNotEmpty) {
      return widget.product.imageUrls.first;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductPage(product: widget.product),
        ),
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: widget.height * 0.65,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) {
                      setState(() {
                        _currentPage = i;
                      });
                    },
                    itemCount: widget.product.imageUrls.length,
                    itemBuilder: (_, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.product.imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
                if (widget.product.imageUrls.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: widget.product.imageUrls.length,
                        effect: const WormEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          dotColor: Colors.white54,
                          activeDotColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RatingBar.builder(
                        initialRating: _currentRating,
                        minRating: 1,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 18,
                        itemBuilder: (_, __) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          _currentRating = rating;
                          _saveRating(rating);
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Promedio: ${_averageRating.toStringAsFixed(1)} ($_ratingCount)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<CartProvider>().addItem(
                              id: _getProductId(),
                              name: widget.product.name,
                              price: widget.product.price.toDouble(),
                              imageUrl: _getMainImage(),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.product.name} agregado al carrito',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text('Agregar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}