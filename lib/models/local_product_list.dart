import 'package:my_new_project/models/product.dart';

// Clase que gestiona productos locales
class LocalProductService {
  // Lista local de productos
  final List<Product> products = [
    Product(
      id: 'iphone_001',
      imageUrls: [
        'https://i.imgur.com/pKWSR08.jpg',
        'https://i.imgur.com/Ort5tWN.jpg',
        'https://i.imgur.com/IXfsIJJ.jpg',
        'https://i.imgur.com/zJIjhZu.jpg',
      ],
      name: 'iPhone',
      description: 'Modelos con lentes y case incluidos.',
      price: 25000,
      category: 'Smartphones',
    ),
    Product(
      id: 'samsung_a22',
      imageUrls: [
        'https://i.imgur.com/Zap1XCB.jpg',
        'https://i.imgur.com/xlucFE2.jpg',
      ],
      name: 'Samsung A22',
      description: 'Disponible en versión 4G y 5G.',
      price: 30000,
      category: 'Smartphones',
    ),
    Product(
      id: 'redmi_14c',
      imageUrls: [
        'https://i.imgur.com/GEWI08P.jpg',
        'https://i.imgur.com/650xpzR.jpg',
        'https://i.imgur.com/4mejGU4.jpg',
      ],
      name: 'Redmi 14C',
      description: 'También disponible en modelo 12.',
      price: 25000,
      category: 'Smartphones',
    ),
    Product(
      id: 'samsung_camera',
      imageUrls: [
        'https://i.imgur.com/Ghrw0g5.jpg',
        'https://i.imgur.com/Mk5phUn.jpg',
        'https://i.imgur.com/3NUtyhr.jpg',
        'https://i.imgur.com/U9KP4c5.jpg',
        'https://i.imgur.com/7hjCxbU.jpg',
        'https://i.imgur.com/IkyYPoB.jpg',
        'https://i.imgur.com/MtMle6w.jpg',
        'https://i.imgur.com/BngXOfK.jpg',
        'https://i.imgur.com/EKmFTAk.jpg',
      ],
      name: 'Cámara Digital Samsung',
      description: 'Cámara digital de alta resolución con múltiples accesorios.',
      price: 300000,
      category: 'Cámaras',
    ),
  ];

  // Método para obtener todos los productos
  List<Product> getProducts() {
    return products;
  }

  // Método para obtener productos por categoría
  List<Product> getProductsByCategory(String category) {
    return products.where((product) => product.category == category).toList();
  }
}
