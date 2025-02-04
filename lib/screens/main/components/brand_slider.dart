import 'dart:async';
import 'package:flutter/material.dart';

class BrandSlider extends StatefulWidget {
  @override
  _BrandSliderState createState() => _BrandSliderState();
}

class _BrandSliderState extends State<BrandSlider> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late Timer _timer;

  final List<String> _brands = [
    'Samsung', 'Apple', 'Xiaomi', 'Oppo', 'Vivo', 'Realme', 'OnePlus', 'Motorola', 'Nokia', 'Huawei', 'Sony', 'LG'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    const scrollDuration = Duration(seconds: 10);
    _timer = Timer.periodic(scrollDuration, (timer) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: scrollDuration,
          curve: Curves.linear,
        ).then((_) {
          _scrollController.jumpTo(0); // Reiniciar el scroll cuando llegue al final
        });
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
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _brands.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Chip(
              label: Text(
                _brands[index],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }
}
