import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:my_new_project/providers/cart_provider.dart';
import 'package:my_new_project/screens/cart/cart_page.dart';

import 'package:my_new_project/models/product.dart';
import 'package:my_new_project/screens/profile_page.dart';
import 'package:my_new_project/screens/shop/check_out_page.dart';
import '../../app_properties.dart';
import '../../custom_background.dart';
import '../../models/local_product_list.dart';
import '../../models/recomendacion_stock_response.dart';
import '../ProfilePage/about_page.dart';
import '../ProfilePage/contact_page.dart';
import '../ProfilePage/privacy_page.dart';
import '../category/category_list_page.dart';

import '../crypto_dashboard_screen.dart';
import '../service/recomendaciones_page.dart';
import '../service/rust_api_chat_service.dart';
import 'components/banner_widget.dart';
import 'components/custom_bottom_bar.dart';
import 'components/product_list.dart';
import 'components/tab_view.dart';
import 'components/brand_slider.dart';
import 'package:my_new_project/screens/category/category_provider.dart';

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

  // Tabs visibles
  final List<String> tabNames = [
    'Promo',
    'Celulares',
    'Protectores Celular',
    'Audífonos',
    'Cámaras',
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabNames.length, vsync: this);
    bottomTabController = TabController(length: 5, vsync: this);
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: timelines.map((timeline) {
          final bool selected = timeline == selectedTimeline;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTimeline = timeline;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(vertical: 1, horizontal: 2),
              decoration: BoxDecoration(
                color: selected ? Colors.black87 : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: selected ? Colors.black : Colors.grey.shade400,
                  width: 1.3,
                ),
              ),
              child: Text(
                timeline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: selected ? 16 : 14,
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twin Yogo'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
        bottomNavigationBar: CustomBottomBar(controller: bottomTabController),

        // WhatsApp button
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            const url =
                'https://wa.me/573209120172?text=Hola%20quiero%20más%20info%20de%20tu%20tienda%20tecnológica';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            }
          },
          backgroundColor: Colors.green,
          child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
        ),

        body: Stack(
          children: [
            CustomPaint(
              painter: MainBackground(),
              child: TabBarView(
                controller: bottomTabController,
                children: <Widget>[
                  SafeArea(
                    child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 350,
                              child: BannerPage(),
                            ),
                          ),
                          SliverToBoxAdapter(child: BrandSlider()),
                          SliverToBoxAdapter(child: _buildTimelineSelector()),
                          SliverToBoxAdapter(child: _buildProductList()),
                          SliverToBoxAdapter(
                            child: TabBar(
                              controller: tabController,
                              tabs: tabNames.map((name) => Tab(text: name)).toList(),
                              labelStyle: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                              unselectedLabelStyle: TextStyle(fontSize: 14.0),
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey.shade700,
                              indicatorColor: Colors.black,
                              isScrollable: true,
                            ),
                          ),
                        ];
                      },
                      body: TabView(tabController: tabController),
                    ),
                  ),
                  CategoryListPage(),
                  CheckOutPage(),
                  ProfilePage(),
                  CryptoDashboardScreen(), // 🔥 NUEVO
                ],
              ),
            ),
// BOTÓN RECOMENDACIONES
            Positioned(
              right: 20,
              bottom: 150, // arriba del WhatsApp
              child: FloatingActionButton(
                heroTag: "recomendacionesBtn",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecomendacionesPage(ref: "Olympus Stylus SZ-16"),
                    ),
                  );
                },
                child: Icon(Icons.inventory),
                backgroundColor: Colors.orange,
              ),

            ),
            // BOTÓN LEGAL
            Positioned(
              left: 20,
              bottom: 80,
              child: FloatingActionButton(
                heroTag: "legalBtn",
                mini: true,
                backgroundColor: Colors.black87,
                child: Icon(Icons.info, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 10),
                          Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.privacy_tip, color: Colors.black),
                            title: Text("Política de Privacidad"),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PrivacyPage()));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.person, color: Colors.black),
                            title: Text("Quiénes Somos"),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => AboutPage()));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.contact_mail, color: Colors.black),
                            title: Text("Contacto"),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => ContactPage()));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
