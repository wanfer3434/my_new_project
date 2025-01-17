import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_card.dart';
import 'recommended_list.dart';
import 'package:ecommerce_int2/screens/category/category_provider.dart';

class TabView extends StatelessWidget {
  final TabController tabController;

  TabView({
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;

    if (categories.isEmpty) {
      return Center(child: Text('No categories available'));
    }

    return TabBarView(
      physics: BouncingScrollPhysics(),
      controller: tabController,
      children: <Widget>[
        // Primer Tab
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lista de categorías
              Container(
                height: 200, // Altura fija para el carrusel de categorías
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CategoryCard(
                        controller: AnimationController(
                          vsync: Scaffold.of(context),
                          duration: const Duration(milliseconds: 300),
                        ),
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
              SizedBox(height: 16),
              // Lista recomendada
              RecommendedList(),
            ],
          ),
        ),
        // Otros Tabs
        Center(child: Text("Tab 2 Content")),
        Center(child: Text("Tab 3 Content")),
        Center(child: Text("Tab 4 Content")),
        Center(child: Text("Tab 5 Content")),
      ],
    );
  }
}
