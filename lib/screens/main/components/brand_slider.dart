import 'dart:async';
import 'package:flutter/material.dart';

class BrandSlider extends StatefulWidget {
  @override
  _BrandSliderState createState() => _BrandSliderState();
}

class _BrandSliderState extends State<BrandSlider> {
  final List<Map<String, dynamic>> brands = [
    {'name': 'Samsung', 'color': Colors.blue},
    {'name': 'Apple', 'color': Colors.black},
    {'name': 'Xiaomi', 'color': Colors.orange},
    {'name': 'Oppo', 'color': Colors.green},
    {'name': 'Vivo', 'color': Colors.purple},
    {'name': 'Realme', 'color': Colors.yellow},
    {'name': 'OnePlus', 'color': Colors.red},
    {'name': 'Motorola', 'color': Colors.teal},
    {'name': 'Nokia', 'color': Colors.blueAccent},
    {'name': 'Huawei', 'color': Colors.deepOrange},
    {'name': 'Sony', 'color': Colors.pink},
    {'name': 'LG', 'color': Colors.brown},
  ];

  late ScrollController _scrollController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final nextScroll = currentScroll + 1.5; // Velocidad del desplazamiento

        if (nextScroll >= maxScroll) {
          _scrollController.jumpTo(0); // Reinicia al inicio
        } else {
          _scrollController.animateTo(
            nextScroll,
            duration: const Duration(milliseconds: 30),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // Altura del slider
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: brands.length * 10, // Se repiten para efecto infinito
        itemBuilder: (context, index) {
          final brand = brands[index % brands.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Chip(
              label: Text(
                brand['name'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: brand['color'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
