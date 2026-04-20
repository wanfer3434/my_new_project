import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:my_new_project/app_properties.dart';
import 'package:my_new_project/models/product.dart';
import 'package:my_new_project/screens/product/components/product_card.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final double cardHeight = MediaQuery.of(context).size.height * 0.58;
    final double cardWidth = MediaQuery.of(context).size.width * 0.22;
    const double paginationSize = 8.0;

    return SizedBox(
      height: cardHeight,
      child: Swiper(
        itemCount: products.length,
        itemBuilder: (_, index) {
          return ProductCard(
            height: cardHeight,
            width: cardWidth,
            product: products[index],
          );
        },
        scale: 0.9,
        controller: SwiperController(),
        viewportFraction: 0.6,
        loop: false,
        fade: 0.5,
        pagination: SwiperCustomPagination(
          builder: (context, config) {
            final Color activeColor = mediumYellow;
            final Color color = Colors.grey.withOpacity(.3);
            const double space = 4.0;

            final List<Widget> dots = [];
            final int itemCount = config.itemCount;
            final int activeIndex = config.activeIndex;

            for (int i = 0; i < itemCount; ++i) {
              final bool active = i == activeIndex;
              dots.add(
                Container(
                  key: Key("pagination_$i"),
                  margin: const EdgeInsets.all(space),
                  child: ClipOval(
                    child: Container(
                      width: paginationSize,
                      height: paginationSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? activeColor : color,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: dots,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}