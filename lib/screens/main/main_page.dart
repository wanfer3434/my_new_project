import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/notifications_page.dart';
import 'package:ecommerce_int2/screens/profile_page.dart';
import 'package:ecommerce_int2/screens/shop/check_out_page.dart';
import '../../custom_background.dart';
import '../../models/local_product_list.dart';
import '../category/category_list_page.dart';
import '../chat_page.dart';
import '../service/chat_service.dart';
import 'components/AnotherPage.dart';
import 'components/banner_widget.dart';
import 'components/custom_bottom_bar.dart';
import 'components/product_list.dart';
import 'components/tab_view.dart';

List<String> timelines = [
  'Destacado Semana',
  'lo ultimo del mes',
  'Mejor de 2025',
];
String selectedTimeline = 'Presentado Semanalmente';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController tabController;
  late TabController bottomTabController;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  List<Product> products = [];
  List<Product> searchResults = [];

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
    searchController.dispose();
    super.dispose();
  }

  void _filterSearchResults(String query) {
    List<Product> tempList = [];
    if (query.isNotEmpty) {
      products.forEach((product) {
        if (product.name.toLowerCase().contains(query.toLowerCase())) {
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

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        _filterSearchResults('');
      }
    });
  }

  Widget _buildProductList() {
    if (isSearching) {
      _filterSearchResults(searchController.text);
    }

    return ProductList(
      products: isSearching ? searchResults : products,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget topHeader = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
          child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timelines[0];
              });
            },
            child: Text(
              timelines[0],
              style: TextStyle(
                fontSize: timelines[0] == selectedTimeline ? 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Flexible(
          child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timelines[1];
              });
            },
            child: Text(
              timelines[1],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: timelines[1] == selectedTimeline ? 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Flexible(
          child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timelines[2];
              });
            },
            child: Text(
              timelines[2],
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: timelines[2] == selectedTimeline ? 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );

    Widget tabBar = TabBar(
      tabs: [
        Tab(text: 'Tendencia'),
        Tab(text: 'Deportes'),
        Tab(text: 'Audífonos'),
        Tab(text: 'Inalámbricos'),
        Tab(text: 'Bluetooth'),
      ],
      labelStyle: TextStyle(fontSize: 16.0),
      unselectedLabelStyle: TextStyle(fontSize: 14.0),
      labelColor: Colors.grey,
      unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.5),
      isScrollable: true,
      controller: tabController,
    );

    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('Tienda de Javier')
            : TextField(
          controller: searchController,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Buscar...',
            hintStyle: TextStyle(color: Colors.black),
            border: InputBorder.none,
          ),
          onChanged: _filterSearchResults,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/search_icon.svg',
              height: 24,
              width: 24,
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
          children: <Widget>[
            SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: 250, // Ajusta la altura del banner
                      pinned: true,
                      primary: false, // Permite superposición con la barra de estado
                      flexibleSpace: FlexibleSpaceBar(
                        background: BannerWidget(
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
                    SliverToBoxAdapter(child: topHeader),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView( // Envuelve en scroll si es necesario.
                        child: Column(
                          children: [
                            _buildProductList(), // Lista de productos.
                            SizedBox(height: 4), // Espacio entre elementos.
                            tabBar, // TabBar adicional.
                          ],
                        ),
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
          ],
        ),
      ),
    );
  }
}

ChatGPT dijo:
ChatGPT
Si deseas verificar el funcionamiento únicamente del widget TabView y descartar temporalmente los demás widgets, puedes simplificar el método build de tu clase MainPage de la siguiente manera:

dart
Copiar código
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Tienda de Javier'),
    ),
    body: TabView(
      tabController: tabController,
    ),
  );
}
Cambios realizados:
Eliminado el CustomPaint: No se utiliza el fondo personalizado.
Eliminado CustomBottomBar y TabBarView: Solo TabView queda como el widget principal en el cuerpo de la página.
AppBar simplificado: No incluye búsqueda ni iconos adicionales.
Sin dependencias de otros widgets: Se omiten el banner, las categorías y la lista de productos.
Esto te permitirá confirmar si el problema persiste al usar únicamente el TabView. Si esto funciona correctamente en el despliegue de Firebase, el problema probablemente está relacionado con uno de los otros widgets o su implementación.






Dijiste:
Indique el código completo 
ChatGPT dijo:
ChatGPT
Aquí tienes el código completo de la clase MainPage simplificado para mostrar únicamente el widget TabView:

dart
Copiar código
import 'package:flutter/material.dart';
import 'components/tab_view.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tienda de Javier'),
      ),
      body: TabView(
        tabController: tabController,
      ),
    );
  }
}
Explicación:
Imports mínimos necesarios: Solo se importa TabView desde su ubicación en components/tab_view.dart.

Estado mínimo: La clase mantiene únicamente el TabController, que controla las pestañas del TabView.

Método build simplificado:

El AppBar incluye únicamente un título.
El body contiene exclusivamente el widget TabView.
Probar en Firebase:
Este código elimina cualquier complejidad adicional, por lo que es ideal para diagnosticar si el problema está en el widget TabView o en otros componentes que habías implementado.






Dijiste:
Quítale el builproduct list, y dejé solo el tabview, indíqueme todo el código completo y solucionado import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/notifications_page.dart';
import 'package:ecommerce_int2/screens/profile_page.dart';
import 'package:ecommerce_int2/screens/shop/check_out_page.dart';
import '../../custom_background.dart';
import '../../models/local_product_list.dart';
import '../category/category_list_page.dart';
import '../chat_page.dart';
import '../service/chat_service.dart';
import 'components/AnotherPage.dart';
import 'components/banner_widget.dart';
import 'components/custom_bottom_bar.dart';
import 'components/product_list.dart';
import 'components/tab_view.dart';

List<String> timelines = [
  'Destacado Semana',
  'lo ultimo del mes',
  'Mejor de 2025',
];
String selectedTimeline = 'Presentado Semanalmente';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController tabController;
  late TabController bottomTabController;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  List<Product> products = [];
  List<Product> searchResults = [];

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
    searchController.dispose();
    super.dispose();
  }

  void _filterSearchResults(String query) {
    List<Product> tempList = [];
    if (query.isNotEmpty) {
      products.forEach((product) {
        if (product.name.toLowerCase().contains(query.toLowerCase())) {
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

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        _filterSearchResults('');
      }
    });
  }

  Widget _buildProductList() {
    if (isSearching) {
      _filterSearchResults(searchController.text);
    }

    return ProductList(
      products: isSearching ? searchResults : products,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget topHeader = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
          child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timelines[0];
              });
            },
            child: Text(
              timelines[0],
              style: TextStyle(
                fontSize: timelines[0] == selectedTimeline ? 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Flexible(
          child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timelines[1];
              });
            },
            child: Text(
              timelines[1],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: timelines[1] == selectedTimeline ? 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Flexible(
          child: InkWell(
            onTap: () {
              setState(() {
                selectedTimeline = timelines[2];
              });
            },
            child: Text(
              timelines[2],
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: timelines[2] == selectedTimeline ? 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );

    Widget tabBar = TabBar(
      tabs: [
        Tab(text: 'Tendencia'),
        Tab(text: 'Deportes'),
        Tab(text: 'Audífonos'),
        Tab(text: 'Inalámbricos'),
        Tab(text: 'Bluetooth'),
      ],
      labelStyle: TextStyle(fontSize: 16.0),
      unselectedLabelStyle: TextStyle(fontSize: 14.0),
      labelColor: Colors.grey,
      unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.5),
      isScrollable: true,
      controller: tabController,
    );

    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('Tienda de Javier')
            : TextField(
          controller: searchController,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Buscar...',
            hintStyle: TextStyle(color: Colors.black),
            border: InputBorder.none,
          ),
          onChanged: _filterSearchResults,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/search_icon.svg',
              height: 24,
              width: 24,
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
          children: <Widget>[
            SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: 250, // Ajusta la altura del banner
                      pinned: true,
                      primary: false, // Permite superposición con la barra de estado
                      flexibleSpace: FlexibleSpaceBar(
                        background: BannerWidget(
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
                    SliverToBoxAdapter(child: topHeader),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView( // Envuelve en scroll si es necesario.
                        child: Column(
                          children: [
                            _buildProductList(), // Lista de productos.
                            SizedBox(height: 4), // Espacio entre elementos.
                            tabBar, // TabBar adicional.
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabView(tabController: tabController),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
ChatGPT dijo:
ChatGPT
Aquí está el código completo de la clase MainPage, eliminando el método _buildProductList y cualquier referencia a él. El enfoque principal es el TabView:

dart
Copiar código
import 'package:flutter/material.dart';
import 'components/tab_view.dart';
import '../../custom_background.dart';
import 'components/banner_widget.dart';
import 'components/custom_bottom_bar.dart';

List<String> timelines = [
  'Destacado Semana',
  'Lo último del mes',
  'Mejor de 2025',
];
String selectedTimeline = 'Destacado Semana';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController tabController;
  late TabController bottomTabController;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    bottomTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    bottomTabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Widget topHeader = Row(
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
              style: TextStyle(
                fontSize: timeline == selectedTimeline ? 20 : 14,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );

    Widget tabBar = TabBar(
      tabs: [
        Tab(text: 'Tendencia'),
        Tab(text: 'Deportes'),
        Tab(text: 'Audífonos'),
        Tab(text: 'Inalámbricos'),
        Tab(text: 'Bluetooth'),
      ],
      labelStyle: TextStyle(fontSize: 16.0),
      unselectedLabelStyle: TextStyle(fontSize: 14.0),
      labelColor: Colors.grey,
      unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.5),
      isScrollable: true,
      controller: tabController,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Tienda de Javier'),
      ),
      bottomNavigationBar: CustomBottomBar(controller: bottomTabController),
      body: CustomPaint(
        painter: MainBackground(),
        child: TabBarView(
          controller: bottomTabController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: 250,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: BannerWidget(
                          imageUrl: 'https://i.imgur.com/GaEsmRG.png',
                          onTap: () {
                            // Acción para el banner
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: topHeader),
                    SliverToBoxAdapter(child: tabBar),
                  ];
                },
                body: TabView(tabController: tabController),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Cambios realizados:
Eliminado _buildProductList: Eliminé tanto el método como cualquier referencia a él.

Mantenimiento del TabView: El widget TabView sigue presente en el TabBarView.

Componentes clave:

TabView: Se utiliza para mostrar el contenido principal.
BannerWidget: Para el banner principal.
Simplificación del AppBar:

Se eliminó la búsqueda dinámica y otras acciones complejas.
Cómo funciona:
Navegación entre pestañas: El TabView sigue funcionando con el tabController.
Estructura minimalista: Se mantiene únicamente lo necesario para evitar conflictos con otros elementos.
Solución de problemas:
Si aún encuentras problemas, verifica que:

El widget TabView esté correctamente implementado en components/tab_view.dart.
Dependencias del proyecto estén actualizadas.
Errores en tiempo de ejecución se solucionen revisando el registro de errores (logcat en Android Studio).











ChatGPT puede cometer er