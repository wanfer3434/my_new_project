import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_card.dart';
import 'recommended_list.dart';
import 'package:ecommerce_int2/screens/category/category_provider.dart';

class TabView extends StatefulWidget {
  final TabController tabController;

  TabView({required this.tabController});

  @override
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;

    if (categories.isEmpty) {
      return Center(child: Text('No categories available'));
    }

    return TabBarView(
      controller: widget.tabController,
      physics: BouncingScrollPhysics(),
      children: [
        // Pestaña 1: Categorías + Lista recomendada
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                //height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CategoryCard(
                        controller: animationController,
                        begin: category.begin,
                        end: category.end,
                        categoryName: category.name ?? 'Unnamed Category',
                        imageUrl: category.imageUrls.isNotEmpty
                            ? category.imageUrls[0]
                            : '',
                        category: category,
                        rating: category.averageRating ?? 0.0,
                        whatsappUrl: category.whatsappUrl ?? '',
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 6),
              RecommendedList(),
            ],
          ),
        ),
        // Pestaña 2: Lista recomendada (puedes personalizarla)
        RecommendedList(),
      ],
    );
  }
}
