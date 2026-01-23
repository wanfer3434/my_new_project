import 'package:flutter/material.dart';
import 'package:my_new_project/models/category.dart';

class CategoryProvider with ChangeNotifier {
  final List<Category> _categories = [
    Category(
      id: 'Silicona',
      begin: const Color(0xffFF512F),
      end: const Color(0xffDD2476),
      name: 'Silicon',
      imageUrls: ['https://i.imgur.com/650xpzR.jpg','https://i.imgur.com/1STDfth.jpeg','https://i.imgur.com/bgD0fw9.jpeg'],
      description: '14c, 13c',
      averageRating: 4.6,
      whatsappUrl: 'https://wa.me/573209120172?text=Hola%20quiero%20más%20info%20de%20tu%20tienda%20tecnológica',
    ),
    Category(
      id: 'Iphone',
      begin: const Color(0xff396AFD),
      end: const Color(0xff2948FF),
      name: 'iPhone',
      imageUrls: ['https://i.imgur.com/ei0dabO.jpg'],
      description: '11, 12, 12 Pro, 12 Pro Max, 13, 14, 13 Pro Max, 14 Pro',
      averageRating: 4.8,
      whatsappUrl: 'https://wa.me/573209120172?text=Hola%20quiero%20más%20info%20de%20tu%20tienda%20tecnológica',
    ),
    Category(
      id: 'Iphone 17',
      begin: const Color(0xff396AFD),
      end: const Color(0xff2948FF),
      name: 'iPhone 17',
      imageUrls: ['https://i.imgur.com/ssY4EvH.jpeg'],
      description: '17',
      averageRating: 5.0,
      whatsappUrl: 'https://wa.me/573209120172?text=Hola%20quiero%20más%20info%20de%20tu%20tienda%20tecnológica',
    ),
    Category(
      id: 'Pines',
      begin: const Color(0xff11998E),
      end: const Color(0xff38EF7D),
      name: 'Pines & Diseño',
      imageUrls: ['https://i.imgur.com/NLzlWUv.jpg'],
      description: 'Camon20, Note13Pro, Note13ProPlus, A24',
      averageRating: 4.4,
      whatsappUrl: 'https://wa.me/573209120172?text=Hola%20quiero%20más%20info%20de%20tu%20tienda%20tecnológica',
    ),
    Category(
      id: 'Silicone',
      begin: const Color(0xff8E2DE2),
      end: const Color(0xff4A00E0),
      name: 'Silicona Colores',
      imageUrls: ['https://i.imgur.com/b8ESxdU.jpg'],
      description: 'Note11, A05, A05S, A15, A35, A55, HOT40, Y9Prime',
      averageRating: 4.5,
      whatsappUrl: 'https://wa.me/573209120172?text=Hola%20quiero%20más%20info%20de%20tu%20tienda%20tecnológica',
    ),
    Category(
      id: 'IphoneD',
      begin: const Color(0xffF7971E),
      end: const Color(0xffFFD200),
      name: 'iPhone Diamantado',
      imageUrls: ['https://i.imgur.com/7wCgiWf.jpg'],
      description: '11, 12, 13, 14, 15',
      averageRating: 4.7,
      whatsappUrl: 'https://wa.me/573209120172?text=Hola%20quiero%20más%20info%20de%20tu%20tienda%20tecnológica',
    ),
    Category(
      id: 'IphoneE',
      begin: const Color(0xffFC5C7D),
      end: const Color(0xff6A82FB),
      name: 'iPhone Escarchado de Colores',
      imageUrls: ['https://i.imgur.com/xBkEJcB.jpg'],
      description: '11, 12, 13 Pro Max',
      averageRating: 4.6,
      whatsappUrl: 'https://wa.me/573209120172?text=Hola%20quiero%20más%20info%20de%20tu%20tienda%20tecnológica',
    ),
  ];

  /// Getter para acceder a las categorías
  List<Category> get categories => _categories;
}
