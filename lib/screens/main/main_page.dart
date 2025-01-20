Import ‘package:cloud_firestore/cloud_firestore.dart’;
Import ‘package:flutter/material.dart’;
Import ‘package:flutter_svg/flutter_svg.dart’;
Import ‘package:ecommerce_int2/models/product.dart’;
Import ‘package:ecommerce_int2/screens/notifications_page.dart’;
Import ‘package:ecommerce_int2/screens/profile_page.dart’;
Import ‘package:ecommerce_int2/screens/shop/check_out_page.dart’;
Import ‘../../custom_background.dart’;
Import ‘../../models/local_product_list.dart’;
Import ‘../category/category_list_page.dart’;
Import ‘../chat_page.dart’;
Import ‘../service/chat_service.dart’;
Import ‘components/AnotherPage.dart’;
Import ‘components/banner_widget.dart’;
Import ‘components/custom_bottom_bar.dart’;
Import ‘components/product_list.dart’;
Import ‘components/tab_view.dart’;

List<String> timelines = [
  ‘Destacado Semana’,
  ‘lo ultimo del mes’,
  ‘Mejor de 2025’,
];
String selectedTimeline = ‘Presentado Semanalmente’;

Class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

Class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  Late TabController tabController;
  Late TabController bottomTabController;
  TextEditingController searchController = TextEditingController();
  Bool isSearching = false;
  List<Product> products = [];
  List<Product> searchResults = [];

  @override
  Void initState() {
    Super.initState();
    tabController = TabController(length: 5, vsync: this);
    bottomTabController = TabController(length: 4, vsync: this);
    products = LocalProductService().getProducts();
  }

  @override
  Void dispose() {
    tabController.dispose();
    bottomTabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Void _filterSearchResults(String query) {
    List<Product> tempList = [];
    If (query.isNotEmpty) {
      Products.forEach((product) {
        If (product.name.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(product);
        }
      });
    } else {
      tempList.addAll(products);
    }
    setState(() {
      searchResults.clear();
      searchResults.addAll(tempList);
    });
  }

  Void _toggleSearch() {
    setState(() {
      isSearching = ¡isSearching;
      if (¡isSearching) {
        searchController.clear();
        _filterSearchResults(‘’);
      }
    });
  }

  Widget _buildProductList() {
    If (isSearching) {
      _filterSearchResults(searchController.text);
    }

    Return ProductList(
      Products: isSearching ¿ searchResults : products,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget topHeader = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
          Child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timelines[0];
              });
            },
            Child: Text(
              Timelines[0],
              Style: TextStyle(
                fontSize: timelines[0] == selectedTimeline ¿ 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Flexible(
          Child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timelines[1];
              });
            },
            Child: Text(
              Timelines[1],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: timelines[1] == selectedTimeline ¿ 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Flexible(
          Child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timelines[2];
              });
            },
            Child: Text(
              Timelines[2],
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: timelines[2] == selectedTimeline ¿ 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );

    Widget tabBar = TabBar(
      Tabs: [
        Tab(text: ‘Tendencia’),
        Tab(text: ‘Deportes’),
        Tab(text: ‘Audífonos’),
        Tab(text: ‘Inalámbricos’),
        Tab(text: ‘Bluetooth’),
      ],
      labelStyle: TextStyle(fontSize: 16.0),
      unselectedLabelStyle: TextStyle(fontSize: 14.0),
      labelColor: Colors.grey,
      unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.5),
      isScrollable: true,
      controller: tabController,
    );

    Return Scaffold(
      appBar: AppBar(
        title: ¡isSearching
            ¿ Text(‘Tienda de Javier’)
            : TextField(
          Controller: searchController,
          Style: TextStyle(color: Colors.black),
          Decoration: InputDecoration(
            hintText: ‘Buscar…’,
            hintStyle: TextStyle(color: Colors.black),
            border: InputBorder.none,
          ),
          onChanged: _filterSearchResults,
        ),
        Actions: <Widget>[
          IconButton(
            Icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NotificationsPage()),
              );
            },
          ),
          IconButton(
            Icon: SvgPicture.asset(
              ‘assets/icons/search_icon.svg’,
              Height: 24,
              Width: 24,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(controller: bottomTabController),
      body: CustomPaint(
        painter: MainBackground(),
        child: TabBarView(
          controller: bottomTabController,
          physics: NeverScrollableScrollPhysics(), // Mantén esto si no quieres swipe en tabs.
          Children: <Widget>[
            SafeArea(
              Child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: 250, // Ajusta la altura del banner
                      pinned: true,
                      primary: false, // Permite superposición con la barra de estado
                      flexibleSpace: FlexibleSpaceBar(
                        background: BannerWidget(
                          imageUrl: ‘https://i.imgur.com/GaEsmRG.png’,
                          onTap: () {
                            Navigator.push(
                              Context,
                              MaterialPageRoute(
                                Builder: (context) => AnotherPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: topHeader),
                    SliverToBoxAdapter(
                      Child: SingleChildScrollView( // Envuelve en scroll si es necesario.
                        Child: Column(
                          Children: [
                            _buildProductList(), // Lista de productos.
                            SizedBox(height: 4), // Espacio entre elementos.
                            tabBar, // TabBar adicional.
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                Body: TabView(tabController: tabController),
              ),
            ),
            CategoryListPage(),
            CheckOutPage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}


