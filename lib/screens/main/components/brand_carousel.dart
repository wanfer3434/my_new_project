import 'dart:async';
import 'package:flutter/material.dart';

class BrandCarousel extends StatefulWidget {
  @override
  _BrandCarouselState createState() => _BrandCarouselState();
}

class _BrandCarouselState extends State<BrandCarousel> {
  final List<String> brands = ['Xiaomi', 'iPhone', 'Samsung', 'Oppo'];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Configurar desplazamiento automático
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final nextScroll = currentScroll + 2.0; // Velocidad del desplazamiento

        if (nextScroll >= maxScroll) {
          _scrollController.jumpTo(0); // Reinicia al inicio
        } else {
          _scrollController.jumpTo(nextScroll);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // Altura del carrusel
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: brands.length * 10, // Multiplicamos para efecto continuo
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            child: Text(
              brands[index % brands.length], // Marca en bucle
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}
