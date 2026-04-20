import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomBar extends StatelessWidget {
  final TabController controller;

  const CustomBottomBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            tooltip: 'Inicio',
            icon: SvgPicture.asset(
              'assets/icons/home_icon.svg',
              fit: BoxFit.fitWidth,
              height: 24,
              width: 24,
            ),
            onPressed: () {
              controller.animateTo(0);
            },
          ),
          IconButton(
            tooltip: 'Categorías',
            icon: Image.asset(
              'assets/icons/category_icon.png',
              height: 24,
              width: 24,
            ),
            onPressed: () {
              controller.animateTo(1);
            },
          ),
          IconButton(
            tooltip: 'Carrito',
            icon: SvgPicture.asset(
              'assets/icons/cart_icon.svg',
              fit: BoxFit.fitWidth,
              height: 24,
              width: 24,
            ),
            onPressed: () {
              controller.animateTo(2);
            },
          ),
          IconButton(
            tooltip: 'Perfil',
            icon: Image.asset(
              'assets/icons/profile_icon.png',
              height: 24,
              width: 24,
            ),
            onPressed: () {
              controller.animateTo(3);
            },
          ),
          IconButton(
            tooltip: 'Crypto',
            icon: Image.asset(
              'assets/icons/crypto_icon.png',
              height: 24,
            ),
            onPressed: () => controller.animateTo(4),
          ),
        ],
      ),
    );
  }
}