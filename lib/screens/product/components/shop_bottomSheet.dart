import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/shop/check_out_page.dart';
import 'package:flutter/material.dart';

import 'shop_product.dart';

class ShopBottomSheet extends StatefulWidget {
  @override
  _ShopBottomSheetState createState() => _ShopBottomSheetState();
}

class _ShopBottomSheetState extends State<ShopBottomSheet> {
  List<Product> products = [
    Product(
      id: 'headphones_400',
      imageUrls: ['assets/headphones.png'],
      name: 'Boat Roackerz 400',
      description: 'Auriculares Bluetooth On-Ear con sonido envolvente.',
      price: 45.3,
      category: 'Auriculares',
    ),
    Product(
      id: 'headphones_100',
      imageUrls: ['assets/headphones_2.png'],
      name: 'Boat Roackerz 100',
      description: 'Auriculares Bluetooth económicos con buen rendimiento.',
      price: 22.3,
      category: 'Auriculares',
    ),
    Product(
      id: 'headphones_300',
      imageUrls: ['assets/headphones_3.png'],
      name: 'Boat Roackerz 300',
      description: 'Versión mejorada con mayor duración de batería.',
      price: 58.3,
      category: 'Auriculares',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Widget confirmButton = InkWell(
      onTap: () async {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckOutPage()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom == 0
              ? 20
              : MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          gradient: mainButton,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              offset: const Offset(0, 5),
              blurRadius: 10.0,
            )
          ],
          borderRadius: BorderRadius.circular(9.0),
        ),
        child: const Center(
          child: Text(
            "Confirmar",
            style: TextStyle(
              color: Color(0xfffefefe),
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.9),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Image.asset(
                'assets/box.png',
                height: 24,
                width: 24,
                fit: BoxFit.cover,
              ),
              onPressed: () {},
              iconSize: 48,
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (_, index) {
                return Row(
                  children: <Widget>[
                    ShopProduct(
                      products[index],
                      onRemove: () {
                        setState(() {
                          if (index < products.length) {
                            products.removeAt(index);
                          }
                        });
                      },
                    ),
                    if (index < products.length - 1)
                      Container(
                        width: 2,
                        height: 200,
                        color: Colors.black.withOpacity(0.1),
                      ),
                  ],
                );
              },
            ),
          ),
          confirmButton,
        ],
      ),
    );
  }
}
