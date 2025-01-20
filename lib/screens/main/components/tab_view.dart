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
    // Inicializamos el AnimationController para usarlo en los widgets.
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    // Nos aseguramos de liberar los recursos del AnimationController.
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos las categorías del proveedor.
    final categories = Provider.of<CategoryProvider>(context).categories;

    // Mostramos un mensaje si no hay categorías.
    if (categories.isEmpty) {
      return Center(child: Text('No categories available'));
    }

    return SizedBox(
      // Aseguramos restricciones de tamaño para el TabBarView.
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: TabBarView(
        physics: BouncingScrollPhysics(), // Física suave para scroll.
        controller: widget.tabController,
        children: <Widget>[
          // Primer Tab con categorías y lista recomendada.
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lista de categorías.
                Container(
                  height: 150, // Altura fija para el carrusel de categorías.
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
                // Lista recomendada.
                RecommendedList(),
              ],
            ),
          ),
          // Otros Tabs.
        ],
      ),
    );
  }
}
