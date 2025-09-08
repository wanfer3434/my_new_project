import 'package:card_swiper/card_swiper.dart';
import 'package:my_new_project/app_properties.dart';
import 'package:my_new_project/models/product.dart';
import 'package:flutter/material.dart';
import 'package:my_new_project/screens/product/components/product_card.dart';
import '../../../firestore_service.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;

  ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    // Ajuste de dimensiones más estándar
    double cardHeight = MediaQuery.of(context).size.height * 0.3; // 30% del alto de la pantalla
    double cardWidth = MediaQuery.of(context).size.width * 0.4; // 40% del ancho de la pantalla
    double paginationSize = 8.0; // Tamaño más pequeño para los puntos de paginación

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
        scale: 0.9, // Proporción ligeramente ajustada
        controller: SwiperController(),
        viewportFraction: 0.6, // Ajuste más pequeño para que se vean más productos en pantalla
        loop: false,
        fade: 0.5,
        pagination: SwiperCustomPagination(
          builder: (context, config) {
            Color activeColor = mediumYellow;
            Color color = Colors.grey.withOpacity(.3);
            double space = 4.0; // Espaciado más compacto

            List<Widget> dots = [];
            int itemCount = config.itemCount;
            int activeIndex = config.activeIndex;

            for (int i = 0; i < itemCount; ++i) {
              bool active = i == activeIndex;
              dots.add(Container(
                key: Key("pagination_$i"),
                margin: EdgeInsets.all(space),
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? activeColor : color,
                    ),
                    width: paginationSize,
                    height: paginationSize,
                  ),
                ),
              ));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0), // Margen reducido
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: dots.map((dot) => dot).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
