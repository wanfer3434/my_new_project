import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/profile_page.dart';
import 'package:ecommerce_int2/screens/shop/check_out_page.dart';
import '../../app_properties.dart';
import '../../custom_background.dart';
import '../../models/local_product_list.dart';
import '../category/category_list_page.dart';
import 'components/AnotherPage.dart';
import 'components/banner_widget.dart';
import 'components/custom_bottom_bar.dart';
import 'components/product_list.dart';
import 'components/tab_view.dart';
import 'components/brand_slider.dart';
import 'package:ecommerce_int2/screens/category/category_provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController tabController;
  late TabController bottomTabController;
  List<Product> products = [];

  List<String> timelines = [
    'Destacado Semana',
    'Lo último del mes',
    'Mejor de 2025',
  ];
  String selectedTimeline = 'Destacado Semana';

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    bottomTabController = TabController(length: 4, vsync: this);
    products = LocalProductService().getProducts();
  }

  @override
  void dispose() {
    tabController.dispose();
    bottomTabController.dispose();
    super.dispose();
  }

  Widget _buildProductList() {
    return ProductList(products: products);
  }

  Widget _buildTimelineSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: timelines.map((timeline) {
        return Flexible(
          child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timeline;
              });
            },
            child: Text(
              timeline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: timeline == selectedTimeline ? 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget tabBar = TabBar(
      controller: tabController,
      tabs: [
        Tab(text: 'Plantas & Diagnóstico'),
        Tab(text: 'Celulares'),
        Tab(text: 'Protectores Celular'),
        Tab(text: 'Audifonos'),
        Tab(text: 'Camaras'),
      ],
      labelStyle: TextStyle(fontSize: 16.0),
      unselectedLabelStyle: TextStyle(fontSize: 14.0),
      labelColor: darkGrey,
      unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.5),
      isScrollable: true,
    );

    return ChangeNotifierProvider(
      create: (_) => CategoryProvider(),
      child: Scaffold(
        bottomNavigationBar: CustomBottomBar(controller: bottomTabController),
        body: CustomPaint(
          painter: MainBackground(),
          child: TabBarView(
            controller: bottomTabController,
            children: <Widget>[
              SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      /// 📌 **BANNER SIN APPBAR**
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200, // Ajusta este valor según necesites
                          child: BannerPage(
                            imageUrl: 'https://i.imgur.com/GaEsmRG.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnotherPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(child: BrandSlider()),
                      SliverToBoxAdapter(child: _buildTimelineSelector()),
                      SliverToBoxAdapter(child: _buildProductList()),
                      SliverToBoxAdapter(child: tabBar),
                    ];
                  },
                  body: TabView(tabController: tabController),
                ),
              ),
              CategoryListPage(),
              CheckOutPage(),
              ProfilePage(),
            ],
          ),
        ),
      ),
    );
  }
}
