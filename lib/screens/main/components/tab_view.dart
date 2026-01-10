import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_new_project/screens/category/category_provider.dart';
import '../../category/market_category_card.dart';
import 'recommended_list.dart';

class TabView extends StatefulWidget {
  final TabController tabController;

  TabView({required this.tabController});

  @override
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with TickerProviderStateMixin {
  late AnimationController animationController;

  /// Lista de tabs y su categoría real
  final List<Map<String, String>> tabCategories = [
    {'tab': 'Edición Limitada', 'category': 'Edición Limitada'},
    {'tab': 'Celulares', 'category': 'Celulares'},
    {'tab': 'Protectores', 'category': 'Protectores Celular'},
    {'tab': 'Audífonos', 'category': 'Audífonos'},
    {'tab': 'Cámaras', 'category': 'Camaras'},
  ];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    widget.tabController.addListener(() {
      if (mounted) {
        setState(() {}); // Actualizar la vista al cambiar pestaña
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;

    return LayoutBuilder(
      builder: (context, constraints) {
        return TabBarView(
          controller: widget.tabController,
          physics: const BouncingScrollPhysics(),
          children: tabCategories.map((tabData) {
            final categoryName = tabData['category']!;
            final filteredCategories = categories
                .where((cat) =>
                cat.name.toLowerCase().contains(categoryName.toLowerCase()))
                .toList();
            final listToShow =
            filteredCategories.isNotEmpty ? filteredCategories : categories;

            return CustomScrollView(
              slivers: [
                // 🔹 Carrusel horizontal de categorías
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 290,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: listToShow.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 190,
                              child: MarketCategoryCard(category: category),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // 🔹 Lista recomendada de productos
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: SafeArea(
                    child: RecommendedList(category: categoryName),
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
