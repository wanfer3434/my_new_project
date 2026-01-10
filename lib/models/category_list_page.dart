import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_new_project/screens/category/category_provider.dart';
import 'package:my_new_project/screens/category/market_category_card.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories =
        Provider.of<CategoryProvider>(context).categories; // Provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return MarketCategoryCard(category: categories[index]);
        },
      ),
    );
  }
}
