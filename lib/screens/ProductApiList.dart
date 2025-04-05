import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/product/components/product_card.dart';

import 'ProductProvider.dart';

class ProductApiList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    if (productProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (productProvider.hasError) {
      return Center(
        child: Text("Error al cargar productos", style: TextStyle(color: Colors.red)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Dos columnas
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7, // Ajusta la proporción de las tarjetas
      ),
      itemCount: productProvider.products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          height: MediaQuery.of(context).size.height * 0.3, // ✅ Agregar height
          width: MediaQuery.of(context).size.width * 0.4,
          product: productProvider.products[index],
        );
      },
    );

  }
}
