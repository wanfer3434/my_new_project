import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/product/view_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rubber/rubber.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  String selectedCategory = ""; // Categoría seleccionada

  final List<Product> products = [
    Product(
        id: 'L325',
        imageUrls: ['assets/headphones_2.png'],
        name: 'Skullcandy headset L325',
        description: 'High-quality headset with immersive sound.',
        price: 102.99,
        category: 'Skull Candy'),
    Product(
        id: 'X25',
        imageUrls: ['assets/headphones_3.png'],
        name: 'Skullcandy headset X25',
        description: 'Noise-canceling headset for superior audio.',
        price: 55.99,
        category: 'Skull Candy'),
    Product(
        id: 'M003',
        imageUrls: ['assets/headphones.png'],
        name: 'Blackzy PRO headphones M003',
        description: 'Professional-grade headphones for audiophiles.',
        price: 152.99,
        category: 'JBL'),
  ];

  final List<String> categoryFilter = [
    'All', // Para mostrar todos los productos
    'Skull Candy',
    'Boat',
    'JBL',
    'Micromax',
    'Seg',
  ];

  List<Product> searchResults = [];
  TextEditingController searchController = TextEditingController();
  late RubberAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RubberAnimationController(
      vsync: this,
      halfBoundValue: AnimationControllerValue(percentage: 0.4),
      upperBoundValue: AnimationControllerValue(percentage: 0.4),
      lowerBoundValue: AnimationControllerValue(pixel: 50),
      duration: Duration(milliseconds: 200),
    );
    searchResults = products; // Inicializa con todos los productos
  }

  void _filterProducts(String query) {
    setState(() {
      searchResults = products.where((product) {
        final matchesName =
        product.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory =
            selectedCategory == "All" || product.category == selectedCategory;
        return matchesName && matchesCategory;
      }).toList();
    });
  }

  Widget _buildSearchField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.orange, width: 1)),
      ),
      child: TextField(
        controller: searchController,
        onChanged: _filterProducts,
        cursorColor: darkGrey,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          prefixIcon: SvgPicture.asset(
            'assets/icons/search_icon.svg',
            fit: BoxFit.scaleDown,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.red),
            onPressed: () {
              searchController.clear();
              _filterProducts('');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<String>(
        value: selectedCategory.isEmpty ? "All" : selectedCategory,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              selectedCategory = newValue;
              _filterProducts(searchController.text);
            });
          }
        },
        items: categoryFilter.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductList() {
    return Expanded(
      child: searchResults.isNotEmpty
          ? ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (_, index) => ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ViewProductPage(product: searchResults[index]),
            ),
          ),
          title: Text(searchResults[index].name),
          subtitle: Text(searchResults[index].category), // Mostrar categoría
        ),
      )
          : Center(child: Text("No products found")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: [CloseButton()],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildCategoryDropdown(),
          _buildProductList(),
        ],
      ),
    );
  }
}
