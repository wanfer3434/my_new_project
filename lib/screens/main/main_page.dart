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
