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

  final List<String> categoryNames = [
    'Plantas & Diagnóstico',
    'Celulares',
    'Tendencia de Protectores',
    'Audífonos',
    'Camaras',
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

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75, // Definir altura fija
      child: TabBarView(
        controller: widget.tabController,
        physics: BouncingScrollPhysics(),
        children: categoryNames.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (categories.isNotEmpty)
                SizedBox(
                  height: 150, // Definir altura de la lista horizontal
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final categoryData = categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CategoryCard(
                          controller: animationController,
                          begin: categoryData.begin,
                          end: categoryData.end,
                          categoryName: categoryData.name ?? 'Sin Nombre',
                          imageUrl: categoryData.imageUrls.isNotEmpty
                              ? categoryData.imageUrls[0]
                              : '',
                          category: categoryData,
                          rating: categoryData.averageRating ?? 0.0,
                          whatsappUrl: categoryData.whatsappUrl ?? '',
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 6),
              Expanded( // Solución al error de altura infinita
                child: RecommendedList(category: category),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
